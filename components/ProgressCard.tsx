
import React from 'react';

interface ProgressCardProps {
    percentage: number;
    completedTasks: number;
    totalTasks: number;
}

const ProgressCard: React.FC<ProgressCardProps> = ({ percentage, completedTasks, totalTasks }) => {
    return (
        <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200 flex flex-col justify-center items-center text-center">
            <h3 className="font-semibold text-slate-900 mb-2">Overall Progress</h3>
            <p className="text-5xl font-bold text-indigo-600">{percentage}%</p>
            <p className="text-slate-600 mt-2">{completedTasks} of {totalTasks} tasks complete</p>
            <div className="w-full bg-slate-200 rounded-full h-2.5 mt-4">
                <div className="bg-indigo-600 h-2.5 rounded-full transition-all duration-500" style={{ width: `${percentage}%` }}></div>
            </div>
        </div>
    );
};

export default ProgressCard;
