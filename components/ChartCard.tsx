
import React, { useRef, useEffect } from 'react';
import { Section } from '../types';

// This tells TypeScript that Chart object is globally available, typically from a CDN script.
declare const Chart: any;

interface ChartCardProps {
    completedByCategory: number[];
    sections: Section[];
}

const ChartCard: React.FC<ChartCardProps> = ({ completedByCategory, sections }) => {
    const canvasRef = useRef<HTMLCanvasElement>(null);
    const chartRef = useRef<any>(null);

    useEffect(() => {
        if (!canvasRef.current) return;
        const ctx = canvasRef.current.getContext('2d');
        if (!ctx) return;
        
        const chartLabels = sections.map(s => s.title);
        const chartData = completedByCategory;
        
        if (chartRef.current) {
            chartRef.current.data.labels = chartLabels;
            chartRef.current.data.datasets[0].data = chartData;
            chartRef.current.update();
        } else {
            chartRef.current = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: chartLabels,
                    datasets: [{
                        label: 'Completed Tasks',
                        data: chartData,
                        backgroundColor: ['#4f46e5', '#f59e0b', '#ef4444', '#10b981', '#64748b', '#06b6d4'],
                        borderColor: '#ffffff',
                        borderWidth: 3,
                        hoverOffset: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '70%',
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                boxWidth: 12,
                                padding: 20,
                                font: { size: 12 },
                                generateLabels: function(chart: any) {
                                    const data = chart.data;
                                    if (data.labels.length && data.datasets.length) {
                                        return data.labels.map((label: string, i: number) => {
                                            const meta = chart.getDatasetMeta(0);
                                            const style = meta.controller.getStyle(i);
                                            const shortLabel = label.split(' ')[0];
                                            
                                            return {
                                                text: `${shortLabel} (${data.datasets[0].data[i]})`,
                                                fillStyle: style.backgroundColor,
                                                strokeStyle: style.borderColor,
                                                lineWidth: style.borderWidth,
                                                hidden: !chart.getDataVisibility(i),
                                                index: i
                                            };
                                        });
                                    }
                                    return [];
                                }
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context: any) {
                                    const section = sections[context.dataIndex];
                                    return ` ${context.dataset.label || ''}: ${context.parsed} of ${section.tasks.length} complete`;
                                }
                            }
                        }
                    }
                }
            });
        }
        
        return () => {
            // No cleanup needed if chart is to persist, but good practice to have for component unmount
        };
    }, [completedByCategory, sections]);

    return (
        <div className="lg:col-span-1 md:col-span-2 bg-white p-6 rounded-xl shadow-sm border border-slate-200 flex flex-col items-center">
            <h3 className="font-semibold text-slate-900 mb-4 text-center">Completion by Category</h3>
            <div className="relative w-full max-w-[450px] mx-auto h-[40vh] max-h-[450px] md:h-[35vh] md:max-h-[300px]">
                <canvas ref={canvasRef}></canvas>
            </div>
        </div>
    );
};

export default ChartCard;
