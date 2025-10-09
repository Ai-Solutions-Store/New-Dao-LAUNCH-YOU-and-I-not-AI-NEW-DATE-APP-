
import React from 'react';
import { Task } from '../types';

interface TaskCardProps {
    task: Task;
    onToggle: () => void;
}

const TaskCard: React.FC<TaskCardProps> = ({ task, onToggle }) => {
    const cardClasses = `
        bg-white p-4 rounded-lg shadow-sm border-l-4 transition-all duration-300 ease-in-out
        ${task.completed ? 'bg-green-50 border-green-500' : 'border-slate-200'}
    `;

    const actionClasses = `
        font-semibold text-slate-800 transition-colors
        ${task.completed ? 'line-through text-slate-500' : ''}
    `;

    return (
        <div className={cardClasses}>
            <label className="flex items-start cursor-pointer">
                <input
                    type="checkbox"
                    className="h-5 w-5 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 mt-1 flex-shrink-0"
                    checked={task.completed}
                    onChange={onToggle}
                />
                <div className="ml-4 flex-1">
                    <div className="flex justify-between items-start">
                        <div>
                            <span className="font-semibold text-slate-500 text-sm">{task.id}</span>
                            <p className={actionClasses}>{task.action}</p>
                        </div>
                        <span className="text-xs font-mono bg-slate-100 text-slate-600 px-2 py-1 rounded flex-shrink-0 ml-2">{task.refs}</span>
                    </div>
                    <p className="text-sm text-slate-600 mt-1">{task.requirement}</p>
                </div>
            </label>
        </div>
    );
};

export default TaskCard;
