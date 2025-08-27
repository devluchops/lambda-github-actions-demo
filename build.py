#!/usr/bin/env python3
import os
import shutil
import subprocess
import zipfile

def build_lambda_package():
    """Build Lambda deployment package locally"""
    
    # Clean dist directory
    if os.path.exists('dist'):
        shutil.rmtree('dist')
    os.makedirs('dist')
    
    # Install dependencies
    subprocess.run([
        'pip', 'install', '-r', 'requirements.txt', '-t', 'dist/'
    ], check=True)
    
    # Copy source code
    shutil.copy('src/lambda_function.py', 'dist/')
    
    # Create zip file
    with zipfile.ZipFile('lambda-function.zip', 'w') as zipf:
        for root, dirs, files in os.walk('dist'):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, 'dist')
                zipf.write(file_path, arcname)
    
    print("Lambda package created: lambda-function.zip")

if __name__ == "__main__":
    build_lambda_package()