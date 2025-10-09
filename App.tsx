
import React, { useState, useMemo, useEffect, useRef } from 'react';
import { Section } from './types';
import { INITIAL_SECTIONS_DATA, METRICS_DATA } from './constants';
import Sidebar from './components/Sidebar';
import Dashboard from './components/Dashboard';
import TaskSection from './components/TaskSection';
import Assistant from './components/Assistant';

const App: React.FC = () => {
    const [sections, setSections] = useState<Section[]>(INITIAL_SECTIONS_DATA);
    const [activeSectionId, setActiveSectionId] = useState<string>(sections[0]?.id || '');

    const sectionRefs = useRef<Map<string, HTMLElement>>(new Map());

    useEffect(() => {
        const observer = new IntersectionObserver(
            (entries) => {
                entries.forEach((entry) => {
                    if (entry.isIntersecting) {
                        setActiveSectionId(entry.target.id);
                    }
                });
            },
            { rootMargin: "-50% 0px -50% 0px" } 
        );

        const currentRefs = sectionRefs.current;
        currentRefs.forEach((sectionEl) => {
            observer.observe(sectionEl);
        });

        return () => {
            currentRefs.forEach((sectionEl) => {
                observer.unobserve(sectionEl);
            });
        };
    }, [sections]);

    const handleToggleTask = (sectionId: string, taskId: string) => {
        setSections(prevSections =>
            prevSections.map(section => {
                if (section.id === sectionId) {
                    return {
                        ...section,
                        tasks: section.tasks.map(task =>
                            task.id === taskId ? { ...task, completed: !task.completed } : task
                        ),
                    };
                }
                return section;
            })
        );
    };

    const progressStats = useMemo(() => {
        let totalTasks = 0;
        let completedTasks = 0;
        const completedByCategory = sections.map(section => {
            const sectionCompleted = section.tasks.filter(t => t.completed).length;
            totalTasks += section.tasks.length;
            completedTasks += sectionCompleted;
            return sectionCompleted;
        });

        const percentage = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

        return {
            totalTasks,
            completedTasks,
            percentage,
            completedByCategory,
        };
    }, [sections]);
    
    return (
        <div className="flex flex-col md:flex-row min-h-screen">
            <Sidebar sections={sections} activeSectionId={activeSectionId} />
            <main className="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto">
                <Dashboard
                    progressStats={progressStats}
                    metrics={METRICS_DATA}
                    sections={sections}
                />
                <div className="space-y-12">
                    {sections.map(section => (
                        <TaskSection
                            key={section.id}
                            section={section}
                            onToggleTask={handleToggleTask}
                            ref={el => {
                                if (el) {
                                    sectionRefs.current.set(section.id, el);
                                } else {
                                    sectionRefs.current.delete(section.id);
                                }
                            }}
                        />
                    ))}
                </div>
            </main>
            <Assistant />
        </div>
    );
};

export default App;