import azure.functions as func
from azure.storage.blob import BlobServiceClient, ContentSettings, generate_blob_sas, BlobSasPermissions
from azure.ai.documentintelligence import DocumentIntelligenceClient
from azure.core.credentials import AzureKeyCredential
from datetime import datetime, timedelta
from io import BytesIO
import os
import logging
import pandas as pd
import json
import uuid

app = func.FunctionApp()

@app.route(route="upload-invoice", methods=["POST"], auth_level=func.AuthLevel.ANONYMOUS)
def upload_invoice(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("📥 Received request to process invoice PDF")

    try:
        file = req.files.get('file')
        if not file:
            return func.HttpResponse("❌ No file uploaded. Use form-data with key 'file'.", status_code=400)

        # Read PDF content
        file_bytes = file.read()
        file_name = file.filename or f"invoice_{uuid.uuid4().hex}.pdf"

        # Analyze with Azure Form Recognizer (Layout Model)
        endpoint = os.getenv("AZURE_FORM_RECOGNIZER_ENDPOINT")
        key = os.getenv("AZURE_FORM_RECOGNIZER_KEY")
        form_client = DocumentIntelligenceClient(endpoint, AzureKeyCredential(key))

        poller = form_client.begin_analyze_document(
            model_id="prebuilt-layout",
            body=file_bytes  # ✅ FIXED: Pass bytes directly
        )
        result = poller.result()

        # Process tables into Excel
        output_stream = BytesIO()
        with pd.ExcelWriter(output_stream, engine='openpyxl') as writer:
            for idx, table in enumerate(result.tables):
                data = []
                for row_idx in range(table.row_count):
                    row = []
                    for col_idx in range(table.column_count):
                        cell = next((c for c in table.cells if c.row_index == row_idx and c.column_index == col_idx), None)
                        row.append(cell.content if cell else "")
                    data.append(row)
                df = pd.DataFrame(data)
                df.to_excel(writer, sheet_name=f"Table_{idx + 1}", index=False)

        output_stream.seek(0)

        # Upload to Blob Storage
        blob_conn_str = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
        blob_service = BlobServiceClient.from_connection_string(blob_conn_str)
        container = "processed"

        base_name = os.path.splitext(file_name)[0]
        blob_name = f"{base_name}.xlsx"
        blob_client = blob_service.get_blob_client(container=container, blob=blob_name)

        blob_client.upload_blob(
            output_stream,
            overwrite=True,
            content_settings=ContentSettings(
                content_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
        )

        # Generate a download URL with SAS token
        sas_token = generate_blob_sas(
            account_name=blob_service.account_name,
            container_name=container,
            blob_name=blob_name,
            account_key=blob_service.credential.account_key,
            permission=BlobSasPermissions(read=True),
            expiry=datetime.utcnow() + timedelta(hours=1)
        )

        download_url = f"https://{blob_service.account_name}.blob.core.windows.net/{container}/{blob_name}?{sas_token}"

        return func.HttpResponse(
            json.dumps({"status": "success", "download_url": download_url}),
            status_code=200,
            mimetype="application/json"
        )

    except Exception as e:
        logging.error(f"❌ Error: {str(e)}")
        return func.HttpResponse(f"Error occurred: {str(e)}", status_code=500)
