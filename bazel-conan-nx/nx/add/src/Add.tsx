import { type DescService } from '@bufbuild/protobuf';
import { createClient, type Client } from '@connectrpc/connect';
import { createConnectTransport } from '@connectrpc/connect-web';
import { Calculator } from '@dummy/protos_connectrpc';
import { useEffect, useMemo, useState } from 'react';

const transport = createConnectTransport({
  baseUrl: 'http://localhost:3000',
});

function useConnectRpcClient<T extends DescService>(service: T): Client<T> {
  return useMemo(() => createClient(service, transport), [service]);
}

export function Add() {
  const [a, setA] = useState(0);
  const [b, setB] = useState(0);
  const [c, setC] = useState(0);

  const calculator = useConnectRpcClient(Calculator);

  useEffect(() => {
    const asyncAdd = async () => {
      const res = await calculator.add({ a: a, b: b });
      setC(res.c);
    };

    asyncAdd().catch(console.error);
  }, [a, b, calculator]);

  const inputStyle =
    '[&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none [appearance:textfield] bg-opacity-10 bg-red-400 border-b border-red-800';
  const wordStyle = 'font-mono mx-1 p-2 text-center text-xl w-20';

  return (
    <div>
      <input
        type="number"
        className={inputStyle + ' ' + wordStyle}
        value={a}
        onChange={e => setA(parseInt(e.target.value))}
        onFocus={e => e.target.select()}
      />
      <span className={wordStyle}>+</span>
      <input
        type="number"
        className={inputStyle + ' ' + wordStyle}
        value={b}
        onChange={e => setB(parseInt(e.target.value))}
        onFocus={e => e.target.select()}
      />
      <span className={wordStyle}>=</span>
      <span className={wordStyle}>{c}</span>
    </div>
  );
}

export default Add;
