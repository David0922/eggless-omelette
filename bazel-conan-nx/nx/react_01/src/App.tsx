import { Add } from '@dummy/add';

function App() {
  return (
    <div
      className="w-screen min-h-screen flex items-center justify-center"
      style={{
        backgroundAttachment: 'fixed',
        backgroundBlendMode: 'lighten',
        backgroundColor: 'rgba(255, 255, 255, 0.9)',
        backgroundImage: 'url(/pokeball.png)',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat',
        backgroundSize: 'contain',
      }}
    >
      <Add />
    </div>
  );
}

export default App;
