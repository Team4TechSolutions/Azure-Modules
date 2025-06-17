// src/App.jsx
import { useState } from "react";
import axios from "axios";
import "./index.css";

function App() {
  const [file, setFile] = useState(null);
  const [uploading, setUploading] = useState(false);
  const [downloadLink, setDownloadLink] = useState("");
  const [error, setError] = useState("");

  const handleFileChange = (e) => {
    setFile(e.target.files[0]);
    setDownloadLink("");
    setError("");
  };

  const handleUpload = async () => {
    if (!file) {
      setError("Please select a PDF file first.");
      return;
    }

    const formData = new FormData();
    formData.append("file", file);

    try {
      setUploading(true);
      setError("");

      const response = await axios.post(
        "https://team4techsolutions-fileconverter-exf7ayf0bmfefnfx.canadacentral-01.azurewebsites.net/api/upload-invoice",
        formData,
        {
          headers: { "Content-Type": "multipart/form-data" },
        }
      );

      setDownloadLink(response.data.download_url);
    } catch (err) {
      setError(err.response?.data || "Upload failed.");
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-4 bg-gray-100">
      <h1 className="text-3xl font-bold mb-6 text-center text-gray-800">
        Invoice PDF to Excel Converter
      </h1>

      <input
        type="file"
        accept="application/pdf"
        onChange={handleFileChange}
        className="mb-4"
      />

      <button
        onClick={handleUpload}
        className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg disabled:opacity-50"
        disabled={uploading}
      >
        {uploading ? "Uploading..." : "Upload & Convert"}
      </button>

      {downloadLink && (
        <div className="mt-6">
          <a
            href={downloadLink}
            target="_blank"
            rel="noopener noreferrer"
            className="text-green-600 font-medium"
          >
            ✅ Download Excel
          </a>
        </div>
      )}

      {error && (
        <p className="text-red-600 mt-4 font-medium">❌ {error}</p>
      )}
    </div>
  );
}

export default App;
