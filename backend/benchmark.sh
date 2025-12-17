#!/bin/bash
# Benchmark Snow Edge AI TTS Backend
# Tests performance with varying text lengths

API_URL="http://localhost:8000/api/tts"

# Function to get backend memory
get_memory() {
    ps aux | grep "python.*main.py" | grep -v grep | awk '{printf "%.1f", $6/1024}'
}

# Function to benchmark a text
benchmark_text() {
    local text="$1"
    local label="$2"
    local chars=${#text}
    
    echo ""
    echo "🔍 Testing: $label ($chars chars)"
    
    # Get memory before
    mem_before=$(get_memory)
    
    # Make request and measure time
    start=$(date +%s.%N)
    response=$(curl -s -w "\n%{http_code}\n%{size_download}" -X POST "$API_URL" \
        -d "text=$text" \
        -d "voice_style=F1" \
        -d "total_step=10" \
        -d "speed=1.0" \
        -o /tmp/tts_output.wav 2>/dev/null)
    end=$(date +%s.%N)
    
    # Calculate elapsed time
    elapsed=$(echo "$end - $start" | bc)
    
    # Parse response
    http_code=$(echo "$response" | tail -2 | head -1)
    audio_bytes=$(echo "$response" | tail -1)
    audio_kb=$(echo "scale=1; $audio_bytes / 1024" | bc)
    
    # Get memory after
    sleep 1
    mem_after=$(get_memory)
    
    # Print results
    if [ "$http_code" = "200" ]; then
        echo "✅ Time: ${elapsed}s | Audio: ${audio_kb} KB | Mem: ${mem_after} MB"
    else
        echo "❌ Failed (HTTP $http_code)"
    fi
    
    # Store results
    echo "$label,$chars,$elapsed,$audio_kb,$mem_after" >> /tmp/benchmark_results.csv
}

# Main benchmark
echo "============================================================"
echo "Snow Edge AI TTS Backend Benchmark"
echo "============================================================"

# Check if backend is running
if ! ps aux | grep "python.*main.py" | grep -v grep > /dev/null; then
    echo "❌ Backend not running!"
    exit 1
fi

echo "✅ Backend detected - Memory: $(get_memory) MB"

# Clear results
echo "Label,Chars,Time(s),Audio(KB),Memory(MB)" > /tmp/benchmark_results.csv

# Run benchmarks
benchmark_text "Hello test" "10_chars"

benchmark_text "This is a longer sentence to test the performance." "50_chars"

benchmark_text "The quick brown fox jumps over the lazy dog. This sentence is designed to be exactly one hundred characters long." "100_chars"

benchmark_text "In the heart of a bustling city, where skyscrapers touched the clouds and neon lights painted the night sky, there lived a young programmer who dreamed of changing the world with code and dedication." "200_chars"

benchmark_text "Artificial intelligence has revolutionized the way we interact with technology, enabling machines to understand natural language, recognize patterns, and make decisions that were once thought to be exclusively human capabilities. From voice assistants that help us manage our daily tasks to sophisticated recommendation systems that personalize our online experiences, AI has become an integral part of modern life." "500_chars"

benchmark_text "The development of text-to-speech technology has come a long way since its early beginnings. What started as robotic, monotonous computer voices has evolved into highly natural-sounding speech synthesis that can convey emotion, emphasis, and nuance. Modern TTS systems utilize deep learning models trained on vast datasets of human speech, enabling them to capture the subtle variations in pitch, tone, and rhythm that make speech sound authentic. These advancements have opened up new possibilities for accessibility, allowing visually impaired individuals to consume written content more easily, and for content creators to generate voiceovers at scale. The technology continues to improve, with recent models achieving near-human quality in multiple languages and voices. Applications range from virtual assistants and audiobook narration to real-time translation and communication aids for those with speech impairments. As we look to the future, the integration of multimodal AI systems promises even more sophisticated interactions between humans and machines." "1000_chars"

# Print summary
echo ""
echo "============================================================"
echo "BENCHMARK SUMMARY"
echo "============================================================"
column -t -s ',' /tmp/benchmark_results.csv

# Calculate stats
echo ""
echo "📊 Statistics:"
tail -n +2 /tmp/benchmark_results.csv | awk -F',' '
    { 
        sum_time += $3; 
        if ($5 > max_mem) max_mem = $5; 
        count++ 
    } 
    END { 
        printf "   Average time: %.2f s\n", sum_time/count;
        printf "   Peak memory: %.1f MB\n", max_mem;
        printf "   Tests run: %d\n", count
    }'
