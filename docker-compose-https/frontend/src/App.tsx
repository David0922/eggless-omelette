import { useEffect, useState } from "react";

function App() {
  const [text, setText] = useState<string>("");

  useEffect(() => {
    const f = async () => {
      const res = await fetch("/api/text");
      setText(await res.text());
    };

    f().catch(console.error);
  }, []);

  return (
    <div
      className="w-screen min-h-screen flex items-center justify-center"
      style={{
        backgroundAttachment: "fixed",
        backgroundBlendMode: "lighten",
        backgroundColor: "rgba(255, 255, 255, 0.9)",
        backgroundImage: "url(/pokeball.png)",
        backgroundPosition: "center",
        backgroundRepeat: "no-repeat",
        backgroundSize: "contain",
      }}
    >
      {text}
    </div>
  );
}

export default App;
