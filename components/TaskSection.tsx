
import React, { forwardRef } from 'react';
import { Section } from '../types';
import TaskCard from './TaskCard';

interface TaskSectionProps {
    section: Section;
    onToggleTask: (sectionId: string, taskId: string) => void;
}

const TaskSection = forwardRef<HTMLElement, TaskSectionProps>(({ section, onToggleTask }, ref) => {
    return (
        <section id={section.id} className="scroll-mt-20" ref={ref}>
            <div className="flex items-center mb-4">
                <span className="text-3xl mr-4">{section.icon}</span>
                <div>
                    <h3 className="text-2xl font-bold text-slate-900">{section.title}</h3>
                    <p className="text-slate-600">{section.description}</p>
                </div>
            </div>
            <div className="space-y-3">
                {section.tasks.map((task) => (
                    <TaskCard
                        key={task.id}
                        task={task}
                        onToggle={() => onToggleTask(section.id, task.id)}
                    />
                ))}
            </div>
        </section>
    );
});

TaskSection.displayName = 'TaskSection';
export default TaskSection;
