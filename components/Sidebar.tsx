
import React from 'react';
import { Section } from '../types';

interface SidebarProps {
    sections: Section[];
    activeSectionId: string;
}

const Sidebar: React.FC<SidebarProps> = ({ sections, activeSectionId }) => {
    return (
        <nav className="w-full md:w-64 bg-white border-b md:border-b-0 md:border-r border-slate-200 flex-shrink-0">
            <div className="p-4 border-b border-slate-200">
                <h1 className="text-xl font-bold text-slate-900">AI-Solutions.Store</h1>
                <p className="text-sm text-slate-500">Production Control Panel</p>
            </div>
            <div className="p-2 space-y-1">
                {sections.map(section => (
                    <a
                        key={section.id}
                        href={`#${section.id}`}
                        className={`flex items-center p-2 rounded-md text-slate-700 hover:bg-slate-100 transition-colors ${
                            activeSectionId === section.id ? 'bg-indigo-50 text-indigo-700 font-semibold' : ''
                        }`}
                    >
                        <span className="mr-3 text-lg">{section.icon}</span>
                        <span className="text-sm font-medium">{section.title}</span>
                    </a>
                ))}
            </div>
        </nav>
    );
};

export default Sidebar;
