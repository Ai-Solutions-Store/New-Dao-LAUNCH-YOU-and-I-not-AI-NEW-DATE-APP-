
import React from 'react';

interface MetricsCardProps {
    title: string;
    children: React.ReactNode;
}

const MetricsCard: React.FC<MetricsCardProps> = ({ title, children }) => {
    return (
        <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200">
            <h3 className="font-semibold text-slate-900 mb-4">{title}</h3>
            {children}
        </div>
    );
};

export default MetricsCard;
