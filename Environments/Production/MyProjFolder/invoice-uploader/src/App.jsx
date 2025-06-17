import { useState } from "react";

export default function App() {
  const [selectedFile, setSelectedFile] = useState(null);
  const [status, setStatus] = useState("");
  const [downloadUrl, setDownloadUrl] = useState("");

  const handleFileChange = (e) => {
    setSelectedFile(e.target.files[0]);
    setDownloadUrl("");
    setStatus("");
  };

  const handleUpload = async (e) => {
    e.preventDefault();

    if (!selectedFile) {
      setStatus("❗Please select a file first");
      return;
    }

    setStatus("⏳ Uploading and converting...");
    const formData = new FormData();
    formData.append("file", selectedFile);

    try {
      const response = await fetch(
        "https://team4techsolutions-fileconverter-exf7ayf0bmfefnfx.canadacentral-01.azurewebsites.net/api/upload-invoice",
        {
          method: "POST",
          body: formData,
        }
      );

      if (!response.ok) throw new Error("Failed to upload and process");

      const result = await response.json();
      setDownloadUrl(result.download_url);
      setStatus("✅ Conversion complete!");
    } catch (err) {
      console.error(err);
      setStatus(`❌ Error: ${err.message}`);
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-50 p-6">
      <h1 className="text-2xl font-bold mb-4 text-blue-700">🧾 Upload PDF Invoice</h1>

      <form
        onSubmit={handleUpload}
        className="bg-white shadow-lg rounded-xl p-6 space-y-4 w-full max-w-md"
      >
        <input
          type="file"
          accept=".pdf"
          onChange={handleFileChange}
          className="w-full border p-2 rounded-md"
        />

        <button
          type="submit"
          className="w-full bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700"
        >
          Upload and Convert
        </button>

        {status && <p className="text-gray-700 text-sm">{status}</p>}

        {downloadUrl && (
          <a
            href={downloadUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="block text-blue-600 underline mt-4"
          >
            📥 Download Converted Excel
          </a>
        )}
      </form>
    </div>
  );
}
