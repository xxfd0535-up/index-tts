# IndexTTS 快速启动指南（Windows WSL 部署版）

> **⚠️ 本指南专为 Windows 系统 + WSL2 + Ubuntu 部署优化**

高质量中文文本转语音（TTS）模型，支持 GPU 加速推理。在 Windows WSL 环境下经过完整测试。

---

## 📋 系统要求

### 硬件要求

- **操作系统**：Windows 10/11（需要支持 WSL2）
- **虚拟环境**：WSL2（Ubuntu 22.04 LTS 或 Ubuntu 24.04）
- **处理器**：Intel i5 以上或 AMD Ryzen 5 以上
- **内存**：16GB 以上（推荐 32GB）
- **硬盘**：至少 30GB 可用空间
- **GPU**（可选）：NVIDIA 显卡（RTX 3060 以上推荐）
- **显存**：4GB 以上（有 GPU 时）

### 软件要求

- **Python**：3.11+
- **FFmpeg**：6.1+ （WSL 中安装）
- **Git**：用于版本管理
- **uv**：Python 包管理工具（可选但推荐）

---

## 🚀 快速开始（Windows WSL 环境）

### 第 1 步：安装 WSL2 和 Ubuntu

#### 在 Windows PowerShell 中执行（需要管理员权限）

```powershell
# 1. 安装 WSL2
wsl --install

# 2. 更新 WSL
wsl --update

# 3. 列出可用的 Linux 发行版
wsl --list --online

# 4. 安装 Ubuntu 22.04 LTS（推荐）
wsl --install -d Ubuntu-22.04

# 5. 重启计算机
```

#### 首次启动 Ubuntu

```powershell
# 打开 Ubuntu
wsl -d Ubuntu-22.04

# 或直接在 PowerShell 中进入
wsl
```

首次启动会要求创建用户名和密码。

### 第 2 步：WSL 内准备环境

在 WSL Ubuntu 中执行以下命令：

```bash
# 1. 更新系统
sudo apt update
sudo apt upgrade -y

# 2. 安装必要工具
sudo apt install -y build-essential git curl wget

# 3. 安装 Python 3.11
sudo apt install -y python3.11 python3.11-venv python3.11-dev
sudo apt install -y python3-pip

# 4. 安装 FFmpeg（关键！）
sudo apt install -y ffmpeg

# 5. 验证 FFmpeg 安装
ffmpeg -version

# 6. 安装 uv（快速包管理工具，可选）
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 第 3 步：克隆项目

```bash
# 1. 进入合适的目录（例如 /mnt/e/AI-bushu）
cd /mnt/e/AI-bushu

# 2. 克隆项目
git clone https://github.com/xxfd0535-up/index-tts.git
cd index-tts

# 3. 查看文件
ls -la
```

### 第 4 步：安装 Python 依赖

```bash
cd /mnt/e/AI-bushu/index-tts

# 方法 1：使用 uv（推荐，快速）
uv sync --all-extras

# 方法 2：使用 pip
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install gradio
```

### 第 5 步：下载模型文件

⚠️ **重要**：模型文件很大（约 5-6GB），请确保网络稳定！

```bash
cd /mnt/e/AI-bushu/index-tts

# 方法 1：使用 huggingface-cli（推荐）
pip install huggingface-hub
hf download IndexTeam/IndexTTS-1.5 --local-dir=checkpoints

# 方法 2：使用 ModelScope（国内用户推荐，更快）
pip install modelscope
python -c "from modelscope import snapshot_download; snapshot_download('IndexTeam/IndexTTS-1.5', cache_dir='checkpoints')"

# 方法 3：手动从 Hugging Face 下载后上传到 WSL
# https://huggingface.co/IndexTeam/IndexTTS-1.5
```

### 第 6 步：启动 WebUI

```bash
cd /mnt/e/AI-bushu/index-tts

# 启动（自动激活虚拟环境）
uv run webui.py

# 或者手动激活后启动
source .venv/bin/activate
python webui.py
```

#### 在浏览器中打开

Windows PowerShell 或 WSL 中看到类似输出：

```
Running on local URL:  http://127.0.0.1:7860
```

复制链接到浏览器，或直接访问：**http://localhost:7860**

---

## ⚡ GPU 加速配置（Windows WSL + NVIDIA GPU）

### 前置条件

- 电脑有 **NVIDIA 显卡**（RTX 3060 以上推荐）
- **NVIDIA 驱动已安装**（在 Windows 中）

### 第 1 步：验证 GPU 可用

#### 在 WSL 中检查

```bash
# 查看是否识别到 GPU
nvidia-smi

# 输出应该显示您的显卡信息
# 例如：NVIDIA GeForce RTX 4060 with 8GB VRAM
```

### 第 2 步：安装 CUDA 工具包（可选）

```bash
# 如果上面的 nvidia-smi 工作正常，通常已经可以使用 GPU
# 否则可以安装完整的 CUDA 工具包

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC
distribution=$(. /etc/os-release;echo $VERSION_CODENAME)

# Ubuntu 22.04
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /"

sudo apt update
sudo apt install -y cuda-toolkit-12-1
```

### 第 3 步：安装 GPU 版本 PyTorch

```bash
cd /mnt/e/AI-bushu/index-tts

# 激活虚拟环境
source .venv/bin/activate

# 卸载 CPU 版本
pip uninstall torch torchaudio -y

# 安装 GPU 版本（CUDA 12.1）
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu121

# 验证 GPU 支持
python -c "import torch; print(f'GPU Available: {torch.cuda.is_available()}'); print(f'GPU Name: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"None\"}')"
```

### 第 4 步：重启 WebUI

```bash
# 停止当前运行
# 在 WebUI 启动的终端中按 Ctrl+C

# 重新启动
cd /mnt/e/AI-bushu/index-tts
uv run webui.py
```

启动时应该看到类似输出：

```
>> GPU weights restored from: checkpoints/gpt.pth
>> bigvgan weights restored from: checkpoints/bigvgan_generator.pth
Running on local URL:  http://127.0.0.1:7860
```

**没有 CUDA 相关的错误提示** = GPU 已成功启用！

---

## 📁 项目结构

```
index-tts/
├── checkpoints/          # 模型文件目录（约 5-6GB）
│   ├── gpt.pth          # 主模型（~2.5GB）
│   ├── s2mel.pth        # 声学模型（~1.2GB）
│   ├── dvae.pth         # 编码器（~200MB）
│   ├── bigvgan_generator.pth  # 声码器（~500MB）
│   └── bigvgan_discriminator.pth  # 鉴别器（~1.6GB）
│
├── indextts/            # 核心代码
│   ├── models/          # 模型定义
│   ├── utils/           # 工具函数
│   └── infer_v1.py      # 推理脚本
│
├── .venv/               # Python 虚拟环境
├── webui.py             # Web 界面启动脚本
├── requirements.txt     # 依赖列表
├── pyproject.toml       # uv 配置文件
└── README.md            # 项目文档
```

---

## 🎯 使用步骤

### 1. 上传参考音频

- **格式**：WAV、MP3
- **长度**：**3-10 秒**（最佳）
- **质量**：清晰人声，无背景音乐
- **采样率**：16kHz 或 44.1kHz

### 2. 输入合成文本

- **支持**：中文、英文、数字、标点
- **长度**：**50-200 个字**（每次调用）

### 3. 调整参数

- **Temperature**：0.3-0.5（越低越稳定）
- **Top P**：0.8-0.9
- **Top K**：50-100

### 4. 点击"生成"

等待合成完成，下载 MP3 文件到本地。

---

## ⚙️ 常用命令

### 启动 WebUI

```bash
# 方式 1：使用 uv（推荐）
cd /mnt/e/AI-bushu/index-tts
uv run webui.py

# 方式 2：手动激活环境
cd /mnt/e/AI-bushu/index-tts
source .venv/bin/activate
python webui.py
```

### 停止 WebUI

```bash
# 在 WebUI 运行的终端中按：
Ctrl + C

# 或在另一个终端中：
pkill -f webui.py
```

### 进入 WSL

从 Windows PowerShell：

```powershell
# 进入默认 WSL
wsl

# 进入指定发行版
wsl -d Ubuntu-22.04

# 直接执行命令
wsl -d Ubuntu-22.04 -e bash -c "cd /mnt/e/AI-bushu/index-tts && uv run webui.py"
```

### 访问文件

在 Windows 文件管理器中：

```
\\wsl$\Ubuntu-22.04\mnt\e\AI-bushu\index-tts
```

或在 WSL 中访问 Windows 文件：

```bash
# Windows C 盘
cd /mnt/c/

# Windows D 盘
cd /mnt/d/

# Windows E 盘
cd /mnt/e/
```

### 查看日志

```bash
# 实时查看日志
tail -f webui.log

# 查看最后 50 行
tail -50 webui.log

# 搜索错误
grep -i "error" webui.log
```

---

## 🐛 Windows WSL 常见问题

### 问题 1：FFmpeg 无法找到

**症状**：`RuntimeError: FFmpeg not found`

**解决**：

```bash
# 在 WSL 中安装
sudo apt update
sudo apt install -y ffmpeg

# 验证
ffmpeg -version
```

### 问题 2：无法访问 localhost:7860

**症状**：浏览器无法连接到 `http://127.0.0.1:7860`

**解决**：

```bash
# 确认 WebUI 已启动（应该看到 "Running on local URL"）

# 获取 WSL IP 地址
ip addr show | grep "inet " | grep -v 127.0.0.1

# 使用 WSL IP 访问
# 例如：http://172.XX.XX.XX:7860

# 或在 Windows 中查看 WSL2 IP
wsl hostname -I
```

### 问题 3：模型加载失败

**症状**：`RuntimeError: Could not load bigvgan_generator.pth`

**解决**：

```bash
# 检查模型文件是否完整
ls -lh /mnt/e/AI-bushu/index-tts/checkpoints/

# 应该显示 5 个 .pth 文件，总大小约 5-6GB

# 如果缺失，重新下载
hf download IndexTeam/IndexTTS-1.5 --local-dir=/mnt/e/AI-bushu/index-tts/checkpoints
```

### 问题 4：GPU 无法被识别

**症状**：`nvidia-smi` 无法运行

**解决**：

```bash
# 确认 NVIDIA 驱动已在 Windows 中安装
# 在 Windows PowerShell 中运行
nvidia-smi

# 在 WSL 中重试
wsl
nvidia-smi

# 如果仍然失败，可能需要重启 WSL
wsl --shutdown
wsl
```

### 问题 5：磁盘空间不足

**症状**：`No space left on device` 或模型下载失败

**解决**：

```bash
# 查看 WSL 磁盘使用
df -h

# 清理不必要文件
sudo apt clean
sudo apt autoclean

# 查看最大文件
du -sh /* | sort -rh | head -10

# 扩展 WSL 虚拟磁盘（需要管理员权限）
# 在 PowerShell 中
diskpart
select vdisk file="D:\WSL\Ubuntu-D\ext4.vhdx"
expand vdisk maximum=200000
```

### 问题 6：生成音频有噪音

**症状**：输出音频质量差、有杂音

**可能原因**：
- 参考音频质量不好
- 参考音频过长或过短
- 模型文件损坏

**解决**：

```bash
# 检查模型完整性
md5sum /mnt/e/AI-bushu/index-tts/checkpoints/*.pth

# 重新下载模型
rm -rf /mnt/e/AI-bushu/index-tts/checkpoints/*
hf download IndexTeam/IndexTTS-1.5 --local-dir=/mnt/e/AI-bushu/index-tts/checkpoints

# 重启 WebUI
uv run webui.py
```

---

## 📊 性能基准

基于实测数据（Windows WSL2 + E 盘存储）：

| 硬件配置 | 10 秒音频生成时间 | GPU 利用率 | 质量等级 |
|---------|-------------------|-----------|---------|
| CPU 模式（i7-10700K） | 45-60 秒 | 0% | ⭐⭐⭐ |
| GPU 模式（RTX 4060） | 2-5 秒 | 60-85% | ⭐⭐⭐⭐⭐ |
| GPU 模式（RTX 3080） | 1-2 秒 | 90%+ | ⭐⭐⭐⭐⭐ |

---

## 🔄 更新和维护

### 更新项目代码

```bash
cd /mnt/e/AI-bushu/index-tts

# 拉取最新代码
git pull origin main

# 更新依赖
uv sync --all-extras
```

### 更新依赖包

```bash
cd /mnt/e/AI-bushu/index-tts

# 使用 uv 更新
uv sync --upgrade

# 或使用 pip
source .venv/bin/activate
pip install --upgrade -r requirements.txt
```

### 清理缓存

```bash
# 清理 Python 缓存
find . -type d -name __pycache__ -exec rm -r {} +
find . -type f -name "*.pyc" -delete

# 清理 huggingface 缓存
rm -rf ~/.cache/huggingface

# 清理 pip 缓存
pip cache purge
```

---

## 🔗 重要链接

- **项目 GitHub**：https://github.com/xxfd0535-up/index-tts
- **原项目**：https://github.com/index-tts/index-tts
- **模型仓库**：https://huggingface.co/IndexTeam/IndexTTS-1.5
- **报告问题**：https://github.com/xxfd0535-up/index-tts/issues
- **WSL 文档**：https://docs.microsoft.com/en-us/windows/wsl/

---

## 📝 版本信息

| 项目 | 版本 | 状态 |
|------|------|------|
| **IndexTTS** | 1.5 | ✅ 稳定 |
| **PyTorch** | 2.5.1 (CUDA 12.1) | ✅ 测试通过 |
| **Python** | 3.11+ | ✅ 支持 |
| **WSL** | WSL2 | ✅ 推荐 |
| **Ubuntu** | 22.04 LTS / 24.04 | ✅ 支持 |

---

## 💡 最佳实践

✅ **使用 SSD 存储**：将项目放在 SSD 或 NVME 上，速度更快  
✅ **定期备份**：重要文件定期备份到本地 Windows  
✅ **使用 GPU**：有 GPU 时启用，生成速度快 10-50 倍  
✅ **监控温度**：长时间运行时注意 GPU 温度（不超过 85°C）  
✅ **使用清晰音源**：参考音频质量直接影响输出效果  

---

## 📞 获取帮助

遇到问题？按以下顺序排查：

1. ✅ 检查系统要求是否满足
2. ✅ 确认 FFmpeg 已安装（`ffmpeg -version`）
3. ✅ 验证模型文件完整（`ls -lh checkpoints/`）
4. ✅ 查看错误日志（终端输出信息）
5. 🔗 提交 Issue 到 GitHub

---

**祝您使用愉快！** 🎵

*最后更新：2025-10-26 | 在 Windows WSL2 (RTX 4060) 上测试*


