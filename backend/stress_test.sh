#!/bin/bash
# Snow Edge AI - Backend Stress Test
# "Harsh Testing" Suite

API_URL="http://localhost:8000/api/tts"
OUTPUT_DIR="/tmp/stress_test"
mkdir -p "$OUTPUT_DIR"

# Function to get backend memory
get_memory() {
    ps aux | grep "python.*main.py" | grep -v grep | awk '{printf "%.1f", $6/1024}'
}

# Function to make a request (runs in background)
make_request() {
    local id="$1"
    local text="$2"
    local voice="$3"
    
    start=$(date +%s.%N)
    response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
        -d "text=$text" \
        -d "voice_style=$voice" \
        -d "total_step=5" \
        -d "speed=1.0" \
        -o "$OUTPUT_DIR/output_$id.wav" 2>/dev/null)
    
    code=$(echo "$response" | tail -1)
    end=$(date +%s.%N)
    elapsed=$(echo "$end - $start" | bc)
    
    if [ "$code" = "200" ]; then
        echo "✅ Req #$id: Success (${elapsed}s)"
    else
        echo "❌ Req #$id: Failed (HTTP $code)"
    fi
}

echo "============================================================"
echo "🔥 SNOW EDGE AI - HARSH STRESS TEST 🔥"
echo "============================================================"
echo "Initial Memory: $(get_memory) MB"
echo "------------------------------------------------------------"

# TEST 1: CONCURRENCY
# Fire 10 requests simultaneously
echo ""
echo "🚀 TEST 1: CONCURRENCY (10 parallel requests)"
echo "Sending 10 requests at once..."

pids=""
for i in {1..10}; do
    make_request "conc_$i" "This is a concurrency test request number $i to check server stability under load." "M1" &
    pids="$pids $!"
done

# Wait for all to finish
wait $pids
echo "Memory after Concurrency: $(get_memory) MB"

# TEST 2: MAX LOAD
# Send maximum allowed characters (5000)
echo ""
echo "🐘 TEST 2: MAX PAYLOAD (5000 characters)"
echo "Generating 5000 character text..."
long_text=$(printf 'A%.0s' {1..5000})

make_request "max_load" "$long_text" "F1"
echo "Memory after Max Load: $(get_memory) MB"

# TEST 3: RAPID FIRE
# Send 20 requests sequentially but as fast as possible
echo ""
echo "⚡ TEST 3: RAPID FIRE (20 sequential requests)"
start_rapid=$(date +%s)

for i in {1..20}; do
    make_request "rapid_$i" "Rapid fire test short text." "M2"
done

end_rapid=$(date +%s)
duration=$((end_rapid - start_rapid))
echo "Completed 20 requests in ${duration}s"
echo "Memory after Rapid Fire: $(get_memory) MB"

# TEST 4: INVALID INPUTS
echo ""
echo "💣 TEST 4: INVALID INPUTS (Edge Cases)"

# Empty text
echo "Testing Empty Text..."
curl -s -o /dev/null -w "Empty Text: HTTP %{http_code}\n" -X POST "$API_URL" -d "text=" -d "voice_style=F1"

# Invalid Voice
echo "Testing Invalid Voice..."
curl -s -o /dev/null -w "Invalid Voice: HTTP %{http_code}\n" -X POST "$API_URL" -d "text=Hello" -d "voice_style=INVALID"

# Too Long Text (5001 chars)
echo "Testing Text Too Long..."
too_long=$(printf 'A%.0s' {1..5001})
curl -s -o /dev/null -w "Too Long: HTTP %{http_code}\n" -X POST "$API_URL" -d "text=$too_long" -d "voice_style=F1"

echo "------------------------------------------------------------"
echo "🏁 STRESS TEST COMPLETE"
echo "Final Memory: $(get_memory) MB"
echo "============================================================"
