import { useEffect, useState } from 'react';

function App() {
  const [msg, setMsg] = useState('loading...');

  useEffect(() => {
    fetch('/api/echo?msg=goodbye+world')
      .then(res => {
        if (!res.ok) throw new Error(res.statusText);
        return res.text();
      })
      .then(setMsg)
      .catch(console.error);
  }, []);

  return <div className='text-rose-900'>{msg}</div>;
}

export default App;
