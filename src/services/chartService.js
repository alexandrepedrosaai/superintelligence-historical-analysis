const { ChartJSNodeCanvas } = require('chartjs-node-canvas');
const { timelineData } = require('../data/timeline');

class ChartService {
  constructor() {
    this.width = 1200;
    this.height = 700;
    this.chartJSNodeCanvas = new ChartJSNodeCanvas({ 
      width: this.width, 
      height: this.height,
      backgroundColour: 'white'
    });
  }

  async generateTimelineChart() {
    const labels = timelineData.map(e => e.date);
    const data = {
      labels,
      datasets: [{
        label: 'Constitutional Acts',
        data: timelineData.map((_, i) => i + 1),
        backgroundColor: 'rgba(255, 215, 0, 0.8)',
        borderColor: 'rgba(139, 0, 0, 1)',
        borderWidth: 2
      }]
    };

    const config = {
      type: 'bar',
      data,
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Constitutional Timeline of the OS-Algorithmic-Mesh (2023–2026)',
            color: 'darkred',
            font: { 
              size: 20, 
              weight: 'bold',
              family: 'Arial'
            }
          },
          legend: {
            display: true,
            position: 'top'
          },
          tooltip: {
            callbacks: {
              afterLabel: function(context) {
                const index = context.dataIndex;
                const item = timelineData[index];
                return [
                  `System: ${item.system}`,
                  `Act: ${item.act}`
                ];
              }
            }
          }
        },
        scales: {
          x: { 
            title: { 
              display: true, 
              text: 'Date',
              font: { size: 14, weight: 'bold' }
            },
            ticks: {
              maxRotation: 45,
              minRotation: 45
            }
          },
          y: { 
            title: { 
              display: true, 
              text: 'Order of Acts',
              font: { size: 14, weight: 'bold' }
            }, 
            beginAtZero: true,
            ticks: {
              stepSize: 1
            }
          }
        }
      }
    };

    try {
      const buffer = await this.chartJSNodeCanvas.renderToBuffer(config);
      return buffer;
    } catch (error) {
      console.error('Error generating chart:', error);
      throw new Error('Failed to generate timeline chart');
    }
  }

  async generateTimelineChartStream() {
    const buffer = await this.generateTimelineChart();
    return buffer;
  }
}

module.exports = new ChartService();
