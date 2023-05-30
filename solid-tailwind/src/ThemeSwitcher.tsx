import { Component, createEffect, createSignal } from 'solid-js';

type Theme = 'dark' | 'light';

const defaultToDarkTheme = () =>
  'theme' in localStorage
    ? localStorage.theme === 'dark'
    : window.matchMedia('(prefers-color-scheme: dark)').matches;

const ThemeSwitcher: Component = () => {
  const [theme, setTheme] = createSignal<Theme>(
    defaultToDarkTheme() ? 'dark' : 'light'
  );

  createEffect(() => {
    if (theme() === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }

    localStorage.theme = theme();
  });

  return (
    <div>
      <button
        class='border p-2 border-neutral-800 dark:border-neutral-200'
        onclick={() => setTheme(theme() === 'dark' ? 'light' : 'dark')}>
        <span class='block leading-none text-4xl material-symbols-outlined'>{`${theme()}_mode`}</span>
      </button>
    </div>
  );
};

export default ThemeSwitcher;
