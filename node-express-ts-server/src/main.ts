import express, { ErrorRequestHandler } from 'express';

const main = async () => {
  const app = express();

  const bind_addr = '0.0.0.0';
  const port = 3000;

  const errorHandler: ErrorRequestHandler = (err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('something broke\n');
  };

  app.get('/', (req, res) => {
    console.log(`req: ${JSON.stringify(req.headers, null, 2)}`);
    res.send('goodbye world\n');
  });

  app.use(errorHandler);

  app.listen(port, bind_addr, () => {
    console.log(`listening at ${bind_addr}:${port}`);
  });
};

main().catch(err => console.error(err));
