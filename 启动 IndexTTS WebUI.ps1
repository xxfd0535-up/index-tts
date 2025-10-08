# Start IndexTTS WebUI (clean, all-English version)

Write-Host "`nActivating Conda virtual environment..."
conda activate D:\conda_envs\index-ttsxiabo

Write-Host "`nSwitching to IndexTTS project directory..."
cd D:\AIXM03\index-tts

Write-Host "`nStarting WebUI..."
python webui.py

Write-Host "`nIf it runs successfully, open your browser and visit: http://127.0.0.1:7860"

