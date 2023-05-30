import { Component } from 'solid-js';
import ThemeSwitcher from './ThemeSwitcher';

const App: Component = () => {
  return (
    <div class='flex h-screen items-center justify-center bg-neutral-200 text-neutral-800 dark:bg-neutral-800 dark:text-neutral-200'>
      <div class='mr-4'>goodbye world</div>
      <ThemeSwitcher />
    </div>
  );
};

export default App;
