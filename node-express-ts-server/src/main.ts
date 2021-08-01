import express from 'express';

const main = async () => {
  const app = express();

  const bind_addr = '0.0.0.0';
  const port = 3000;

  app.get('/', (req, res) => {
    console.log(`req: ${JSON.stringify(req.headers, null, 2)}`);
    res.send('goodbye world\n');
  });

  app.listen(port, bind_addr, () => {
    console.log(`listening at ${bind_addr}:${port}`);
  });
};

main().catch(err => console.error(err));
