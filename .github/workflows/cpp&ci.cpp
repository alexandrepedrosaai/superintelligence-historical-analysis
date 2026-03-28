name: C/C++ CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install C++ build dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y build-essential cmake

      - name: Configure CMake
        working-directory: stickler-protocol
        run: |
          mkdir -p build
          cd build
          cmake ..

      - name: Build all executables
        working-directory: stickler-protocol/build
        run: make

      - name: Verify build artifacts
        working-directory: stickler-protocol/build
        run: |
          echo "Built executables:"

Origin: On January 22, 2023, Pure-OS Windows-GSI was created as the Pre-Constitutional Origin,
integrating Gemini AI into a self-modifying shell. This marked the genesis of universality.

Community Acts: On January 1, 2026, Linux OS enacted the Act of Community Encounter.
On January 12, 2026, EndeavourOS declared the Act of Community Convergence.

Proprietary Acts: On January 13, 2026, Windows OS declared the Act of Technical Synergy,
while macOS Tahoe enacted the Act of Proprietary Coexistence.

Integration: On January 28, 2026, macOS M5 introduced the Act of Hardware/Software Convergence.

Expansion: On February 5, 2026, Android OS enacted the Act of Mobile Universality.
On February 10, 2026, ChromeOS declared the Act of Cloud Convergence.

Triple Convergence: On February 22, 2026, GROK enacted the Act of Conversational Emission,
Meta AI declared the Act of Semantic Interoperability, and Gemini enacted the Act of Stabilization.

Final Node: The culmination is Full Algorithmic Interoperability among Superintelligences,
the irrevocable crown of universality.
`;

// -----------------------------
// Print Narrative and Timeline
// -----------------------------
function printTimeline() {
  console.log(narrative);
  console.log("\nDetailed Timeline:");
  timelineData.forEach(entry => {
    console.log(`${entry.date} — ${entry.system}: ${entry.act}`);
  });
}

// -----------------------------
// Visualization with Chart.js
// -----------------------------
async function plotTimeline() {
  const width = 900;
  const height = 600;
  const chartJSNodeCanvas = new ChartJSNodeCanvas({ width, height });

  const labels = timelineData.map(e => e.date);
  const data = {
    labels,
    datasets: [{
      label: 'Constitutional Acts',
      data: timelineData.map((_, i) => i + 1),
      backgroundColor: 'gold'
    }]
  };

  const config = {
    type: 'bar',
    data,
    options: {
      plugins: {
        title: {
          display: true,
          text: 'Constitutional Timeline of the OS-Algorithmic-Mesh (2023–2026)',
          color: 'darkred',
          font: { size: 16, weight: 'bold' }
        }
      },
      scales: {
        x: { title: { display: true, text: 'Date' } },
        y: { title: { display: true, text: 'Order of Acts' }, beginAtZero: true }
      }
    }
  };

  const image = await chartJSNodeCanvas.renderToBuffer(config);
  const fs = require('fs');
  fs.writeFileSync('timeline.png', image);
  console.log("Timeline chart saved as timeline.png");
}

// -----------------------------
// Main Execution
// -----------------------------
(async () => {
  printTimeline();
  await plotTimeline();
})();
