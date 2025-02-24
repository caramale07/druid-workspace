import json
import subprocess
import time
import pandas as pd

LOG_FILE = "docker_stats.log"
INTERVAL = 5  # Log every 5 seconds
DURATION = 300  # Run for  seconds

def log_docker_stats():
    """Logs Docker stats to a file at regular intervals."""
    with open(LOG_FILE, "w") as f:
        start_time = time.time()
        while time.time() - start_time < DURATION:
            result = subprocess.run(
                ["docker", "stats", "--no-stream", "--format", "{{json .}}"],
                capture_output=True,
                text=True
            )
            lines = result.stdout.strip().split("\n")
            json_data = [json.loads(line) for line in lines if line]
            f.write(json.dumps(json_data) + "\n")
            time.sleep(INTERVAL)
    print(f"Stats logged to {LOG_FILE}")

def parse_docker_stats():
    """Parses the logged Docker stats and computes min, max, and avg values."""
    stats_list = []
    with open(LOG_FILE, "r") as f:
        for line in f:
            stats_list.extend(json.loads(line))

    # Convert to DataFrame
    df = pd.DataFrame(stats_list)

    # Extract relevant numeric fields
    df["CPU"] = df["CPUPerc"].str.replace("%", "").astype(float)
    df["MEM_USAGE"] = df["MemUsage"].str.split("/").str[0].str.strip().replace(
        {"MiB": "*1e6", "GiB": "*1e9"}, regex=True
    ).map(eval).astype(float)
    df["MEM_LIMIT"] = df["MemUsage"].str.split("/").str[1].str.strip().replace(
        {"MiB": "*1e6", "GiB": "*1e9"}, regex=True
    ).map(eval).astype(float)
    df["MEM_PERCENT"] = df["MemPerc"].str.replace("%", "").astype(float)

    # Extract min, max, and avg
    summary = df.groupby("Name").agg(
        min_cpu=("CPU", "min"),
        max_cpu=("CPU", "max"),
        avg_cpu=("CPU", "mean"),
        min_mem_usage=("MEM_USAGE", "min"),
        max_mem_usage=("MEM_USAGE", "max"),
        avg_mem_usage=("MEM_USAGE", "mean"),
        min_mem_percent=("MEM_PERCENT", "min"),
        max_mem_percent=("MEM_PERCENT", "max"),
        avg_mem_percent=("MEM_PERCENT", "mean"),
    )

    print(summary)
    return summary

# Run logging
log_docker_stats()

# Parse and analyze logs
summary_stats = parse_docker_stats()

# Save to CSV
summary_stats.to_csv("docker_stats_summary-1.csv")
print("Summary saved to docker_stats_summary.csv")
