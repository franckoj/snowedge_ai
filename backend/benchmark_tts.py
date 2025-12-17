#!/usr/bin/env python3
"""
Benchmark script for Snow Edge AI TTS backend.
Tests performance with varying text lengths.
"""

import requests
import time
import psutil
import os
from typing import Dict, List

# Backend URL
API_URL = "http://localhost:8000/api/tts"

# Test texts of increasing length
TEST_TEXTS = {
    "10_chars": "Hello test",
    "50_chars": "This is a longer sentence to test the performance.",
    "100_chars": "The quick brown fox jumps over the lazy dog. This sentence is designed to be exactly one hundred characters long.",
    "200_chars": "In the heart of a bustling city, where skyscrapers touched the clouds and neon lights painted the night sky, there lived a young programmer who dreamed of changing the world with code and dedication.",
    "500_chars": "Artificial intelligence has revolutionized the way we interact with technology, enabling machines to understand natural language, recognize patterns, and make decisions that were once thought to be exclusively human capabilities. From voice assistants that help us manage our daily tasks to sophisticated recommendation systems that personalize our online experiences, AI has become an integral part of modern life. The field continues to evolve rapidly, with new breakthroughs in machine learning and neural networks pushing the boundaries.",
    "1000_chars": "The development of text-to-speech technology has come a long way since its early beginnings. What started as robotic, monotonous computer voices has evolved into highly natural-sounding speech synthesis that can convey emotion, emphasis, and nuance. Modern TTS systems utilize deep learning models trained on vast datasets of human speech, enabling them to capture the subtle variations in pitch, tone, and rhythm that make speech sound authentic. These advancements have opened up new possibilities for accessibility, allowing visually impaired individuals to consume written content more easily, and for content creators to generate voiceovers at scale. The technology continues to improve, with recent models achieving near-human quality in multiple languages and voices. Applications range from virtual assistants and audiobook narration to real-time translation and communication aids for those with speech impairments. As we look to the future, the integration of multimodal AI systems promises even more sophisticated interactions between humans and machines, where text, speech, and visual information seamlessly combine to create rich, engaging experiences."
}

def get_backend_memory() -> float:
    """Get memory usage of the backend process in MB."""
    # Find Python process running main.py
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        try:
            cmdline = proc.info['cmdline']
            if cmdline and 'main.py' in ' '.join(cmdline):
                process = psutil.Process(proc.info['pid'])
                mem_info = process.memory_info()
                return mem_info.rss / (1024 * 1024)  # Convert to MB
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    return 0

def benchmark_text(text: str, label: str) -> Dict:
    """Benchmark a single text input."""
    print(f"\n🔍 Testing: {label} ({len(text)} chars)")
    
    # Measure initial memory
    mem_before = get_backend_memory()
    
    # Make request and measure time
    start_time = time.time()
    try:
        response = requests.post(
            API_URL,
            json={
                "text": text,
                "voice": "F1",
                "denoising_steps": 10,
                "speed": 1.0
            },
            timeout=30
        )
        elapsed = time.time() - start_time
        
        # Check response
        success = response.status_code == 200
        audio_size = len(response.content) if success else 0
        
    except Exception as e:
        print(f"❌ Error: {e}")
        elapsed = time.time() - start_time
        success = False
        audio_size = 0
    
    # Measure memory after
    time.sleep(1)  # Let memory settle
    mem_after = get_backend_memory()
    mem_delta = mem_after - mem_before
    
    result = {
        "label": label,
        "chars": len(text),
        "success": success,
        "time_seconds": round(elapsed, 2),
        "audio_kb": round(audio_size / 1024, 1),
        "mem_before_mb": round(mem_before, 1),
        "mem_after_mb": round(mem_after, 1),
        "mem_delta_mb": round(mem_delta, 1)
    }
    
    # Print results
    status = "✅" if success else "❌"
    print(f"{status} Time: {result['time_seconds']}s | Audio: {result['audio_kb']} KB | Mem: {result['mem_after_mb']} MB (Δ {result['mem_delta_mb']} MB)")
    
    return result

def main():
    """Run benchmark suite."""
    print("=" * 60)
    print("Snow Edge AI TTS Backend Benchmark")
    print("=" * 60)
    
    # Check if backend is running
    if get_backend_memory() == 0:
        print("❌ Backend not running! Start it with: ./venv/bin/python main.py")
        return
    
    print(f"✅ Backend detected - Memory: {get_backend_memory():.1f} MB")
    
    # Run benchmarks
    results = []
    for label, text in TEST_TEXTS.items():
        result = benchmark_text(text, label)
        results.append(result)
        time.sleep(2)  # Pause between tests
    
    # Print summary table
    print("\n" + "=" * 60)
    print("BENCHMARK SUMMARY")
    print("=" * 60)
    print(f"{'Text Length':<15} {'Time (s)':<10} {'Audio (KB)':<12} {'Memory (MB)':<12}")
    print("-" * 60)
    
    for r in results:
        if r['success']:
            print(f"{r['label']:<15} {r['time_seconds']:<10} {r['audio_kb']:<12} {r['mem_after_mb']:<12}")
        else:
            print(f"{r['label']:<15} {'FAILED':<10} {'-':<12} {'-':<12}")
    
    print("-" * 60)
    
    # Calculate averages
    successful = [r for r in results if r['success']]
    if successful:
        avg_time = sum(r['time_seconds'] for r in successful) / len(successful)
        max_mem = max(r['mem_after_mb'] for r in successful)
        print(f"\n📊 Average time: {avg_time:.2f}s")
        print(f"📊 Peak memory: {max_mem:.1f} MB")
        print(f"📊 Success rate: {len(successful)}/{len(results)}")

if __name__ == "__main__":
    main()
