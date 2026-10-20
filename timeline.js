const { ChartJSNodeCanvas } = require('chartjs-node-canvas');
const fs = require('fs');

const timelineData = [
  { date: '2023-01-22', system: 'Pure-OS Windows-GSI', act: 'Origin' },
  { date: '2026-01-01', system: 'Linux OS', act: 'Community Encounter' },
  { date: '2026-01-12', system: 'EndeavourOS', act: 'Community Convergence' },
  { date: '2026-01-13', system: 'Windows OS', act: 'Technical Synergy' },
  { date: '2026-01-13', system: 'macOS Tahoe', act: 'Proprietary Coexistence' },
  { date: '2026-01-28', system: 'macOS M5', act: 'Hardware/Software Convergence' },
  { date: '2026-02-05', system: 'Android OS', act: 'Mobile Universality' },
  { date: '2026-02-10', system: 'ChromeOS', act: 'Cloud Convergence' },
  { date: '2026-02-22', system: 'GROK', act: 'Conversational Emission' },
  { date: '2026-02-22', system: 'Meta AI', act: 'Semantic Interoperability' },
  { date: '2026-02-22', system: 'Gemini', act: 'Stabilization' }
];

function printTimeline() {
  console.log('Detailed Timeline:');

  timelineData.forEach(entry => {
    console.log(`${entry.date} - ${entry.system}: ${entry.act}`);
  });
}

async function plotTimeline() {
  const width = 900;
  const height = 600;

  const chartJSNodeCanvas = new ChartJSNodeCanvas({
    width,
    height
  });

  const config = {
    type: 'bar',
    data: {
      labels: timelineData.map(e => e.date),
      datasets: [{
        label: 'Constitutional Acts',
        data: timelineData.map((_, i) => i + 1),
        backgroundColor: 'gold'
      }]
    },
    options: {
      responsive: false
    }
  };

  const image = await chartJSNodeCanvas.renderToBuffer(config);

  fs.writeFileSync('timeline.png', image);

  console.log('Timeline chart saved as timeline.png');
}

(async () => {
  printTimeline();
  await plotTimeline();
})();
