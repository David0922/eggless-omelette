import express, { ErrorRequestHandler } from 'express';
import mongoose from 'mongoose';

const main = async () => {
  const app = express();

  const bind_addr = '0.0.0.0';
  const port = 3000;

  const errorHandler: ErrorRequestHandler = (err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('something broke\n');
  };

  if (process.env.MONGODB_URI) {
    await mongoose.connect(process.env.MONGODB_URI);
  } else {
    throw new Error('failed to load env var `MONGODB_URI`');
  }

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

main().catch(err => console.error(err));
