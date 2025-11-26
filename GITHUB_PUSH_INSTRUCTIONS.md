# Push to GitHub Instructions

## Step 1: Rename the local directory (optional but recommended)

In your terminal, run:
```bash
cd /Users/francisjoseph/Desktop/Projects
mv supertonic_tts snowedge_ai
cd snowedge_ai
```

## Step 2: Create a new GitHub repository

1. Go to https://github.com/new
2. Repository name: `snowedge-ai`
3. Description: "AI Creative Tools Platform - Text-to-Speech, Image Generation, Video Creation"
4. Choose Public or Private
5. **Do NOT** initialize with README (we already have one)
6. Click "Create repository"

## Step 3: Add GitHub remote and push

Copy the commands from GitHub, or run:

```bash
# Add your GitHub repo as remote
git remote add origin https://github.com/YOUR_USERNAME/snowedge-ai.git

# Push to GitHub
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## Step 4: Verify

Visit your repository at:
```
https://github.com/YOUR_USERNAME/snowedge-ai
```

You should see:
- ✅ 55 files
- ✅ README with Snow Edge AI branding
- ✅ backend/, web/, mobile/ directories
- ✅ All commits

## Important Notes

### Large Files Excluded
The `.gitignore` file excludes:
- `backend/assets/` (~251MB of ONNX models)
- `node_modules/`
- `venv/`
- Build artifacts

### Setup Instructions for Others

Anyone cloning your repo will need to:

1. **Backend setup**:
   ```bash
   cd backend
   ./setup.sh  # Downloads ONNX models
   ```

2. **Web setup**:
   ```bash
   cd web
   npm install
   ```

3. **Mobile setup**:
   ```bash
   cd mobile
   npm install
   ```

## Repository Settings (Optional)

After pushing, you can:
1. Add topics: `ai`, `tts`, `react-native`, `nextjs`, `fastapi`
2. Add a description
3. Enable GitHub Pages for documentation
4. Set up GitHub Actions for CI/CD

## Troubleshooting

If you get authentication errors:
1. Use a Personal Access Token instead of password
2. Or set up SSH keys: https://docs.github.com/en/authentication

If files are too large:
- They should already be excluded by `.gitignore`
- If not, add them to `.gitignore` and commit again
