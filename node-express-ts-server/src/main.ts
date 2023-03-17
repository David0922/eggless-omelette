import express, { ErrorRequestHandler } from 'express';

const main = async () => {
  const app = express();

  const bind_addr = '0.0.0.0';
  const port = 3000;

  const errorHandler: ErrorRequestHandler = (err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('something broke\n');
  };

  app.use(express.json());
  app.use(express.urlencoded());

  app.get('/', (req, res) => {
    console.log(req.headers);
    res.send('goodbye world\n');
  });

  app.use(errorHandler);

  app.listen(port, bind_addr, () => {
    console.log(`listening at ${bind_addr}:${port}`);
  });
};

main().catch(console.error);
