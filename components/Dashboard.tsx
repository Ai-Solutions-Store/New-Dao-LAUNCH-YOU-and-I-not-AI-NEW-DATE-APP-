
import React from 'react';
import { Metrics, Section } from '../types';
import ProgressCard from './ProgressCard';
import MetricsCard from './MetricsCard';
import ChartCard from './ChartCard';

interface DashboardProps {
    progressStats: {
        totalTasks: number;
        completedTasks: number;
        percentage: number;
        completedByCategory: number[];
    };
    metrics: Metrics;
    sections: Section[];
}

const Dashboard: React.FC<DashboardProps> = ({ progressStats, metrics, sections }) => {
    return (
        <div id="overview" className="mb-8">
            <h2 className="text-3xl font-bold text-slate-900 mb-2">Launch Progress Dashboard</h2>
            <p className="text-slate-600 mb-6">This dashboard tracks execution status for the <strong>300% Tokenized DAO Ecosystem</strong> launch, combining operational progress with strategic crypto-financial goals.</p>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <ProgressCard
                    percentage={progressStats.percentage}
                    completedTasks={progressStats.completedTasks}
                    totalTasks={progressStats.totalTasks}
                />
                
                <MetricsCard title="Token-Accelerated Goals">
                    <div className="space-y-2 text-sm">
                        <div className="flex justify-between font-medium">
                            <span className="text-slate-500">Funding Streams</span>
                            <span className="text-indigo-600">{metrics.revenueStreams}</span>
                        </div>
                        <div className="flex justify-between font-medium">
                            <span className="text-slate-500">Year 1 Projection</span>
                            <span className="text-indigo-600">{metrics.y1Projection}</span>
                        </div>
                        <div className="flex justify-between font-medium">
                            <span className="text-slate-500">Year 3 Projection</span>
                            <span className="text-indigo-600">{metrics.y3Projection}</span>
                        </div>
                        <div className="flex justify-between font-medium">
                            <span className="text-slate-500">Legal/Crypto Status</span>
                            <span className="text-green-600">{metrics.complianceStatus}</span>
                        </div>
                    </div>
                </MetricsCard>
                
                <MetricsCard title="DAO Architecture Stack">
                     <ul className="space-y-2 text-sm list-disc pl-5 text-slate-600">
                        {metrics.architecture.map(item => (
                            <li key={item.label} className="text-slate-700">
                                <span className="font-medium">{item.label}:</span> {item.detail}
                            </li>
                        ))}
                    </ul>
                </MetricsCard>

                <ChartCard
                    completedByCategory={progressStats.completedByCategory}
                    sections={sections}
                />
            </div>
        </div>
    );
};

export default Dashboard;
