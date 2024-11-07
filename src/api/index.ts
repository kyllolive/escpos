import express, { Request, Response } from 'express';

import MessageResponse from '../interfaces/MessageResponse';
import emojis from './emojis';
import escpos from 'escpos';


const router = express.Router();

router.get<{}, MessageResponse>('/', (req, res) => {
  res.json({
    message: 'API - 👋🌎🌍🌏',
  });
});

router.use('/emojis', emojis);

router.use('/print', (req: Request, res: Response) => {
  //print to epson lx3100
  res.send('Hello World');
  escpos.USB = require('escpos-usb');
  const device  = new escpos.USB();

  const options = { encoding: 'GB18030' /* default */ };
  // encoding is optional

  const printer = new escpos.Printer(device, options);

  device.open(function (error: any) {
    printer
      .font('A')
      .align('CT')
      .style('BU')
      .size(1, 1)
      .text('The quick brown fox jumps over the lazy dog')
      .text('敏捷的棕色狐狸跳过懒狗')
      .barcode('1234567', 'EAN8')
      .table(['One', 'Two', 'Three'])
      
      .qrimage('https://github.com/song940/node-escpos', function (err: any) {
        this.cut();
        this.close();
      });
  });
});

export default router;
