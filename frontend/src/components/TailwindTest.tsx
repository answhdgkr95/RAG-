import React from 'react';

export const TailwindTest: React.FC = () => {
  return (
    <div className="max-w-md mx-auto bg-white rounded-xl shadow-md overflow-hidden md:max-w-2xl">
      <div className="md:flex">
        <div className="md:shrink-0">
          <div className="h-48 w-full object-cover md:h-full md:w-48 bg-gradient-to-r from-purple-400 via-pink-500 to-red-500 flex items-center justify-center">
            <span className="text-white font-bold text-xl">Tailwind</span>
          </div>
        </div>
        <div className="p-8">
          <div className="uppercase tracking-wide text-sm text-indigo-500 font-semibold">
            CSS Framework
          </div>
          <p className="block mt-1 text-lg leading-tight font-medium text-black">
            Tailwind CSS Test Component
          </p>
          <p className="mt-2 text-slate-500">
            이 컴포넌트는 Tailwind CSS가 정상적으로 작동하는지 확인하기 위한
            테스트 컴포넌트입니다. 그라디언트, 반응형 디자인, 그림자,
            타이포그래피 등 다양한 Tailwind 클래스를 사용합니다.
          </p>
          <div className="mt-4 flex space-x-2">
            <button className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded transition duration-300">
              Primary
            </button>
            <button className="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded transition duration-300">
              Secondary
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
