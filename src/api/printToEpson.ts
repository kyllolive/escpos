import { Printer } from '@node-escpos/core';
import USB from '@node-escpos/usb-adapter';
import express from 'express';
import getMAC from 'getmac';

const router = express.Router();


router.get<{}, any>('/check-status', (req, res) => {
  const device = new USB();
  device.open(function (err) {
    if (err) {
      res.status(500).json({ message: 'Printer not connected' });
    } else {
      res.json({ message: 'Printer connected' });
    }
  });
});

router.post<{}, any>('/', (req, res) => {
  const { body } = req;
  const device = new USB();

  device.open(async function (err) {
    if (err) {
      console.error('Error opening device:', err);
      res.status(500).json({ message: 'Error opening device' });
      return;
    }

    const options = { encoding: 'UTF-8' };

    let printer = new Printer(device, options);

    try {
      printer.font('a').text(body.message);
      //printer.cut();
      await printer.close();
      res.json({ message: 'Printed' });
    } catch (error) {
      console.error('Error printing:', error);
      res.status(500).json({ message: 'Error printing' });
    } finally {
      device.close();
    }
  });
});

router.get<{}, any>('/mac-address', (req, res) => {
  try {

    const macAddress = getMAC();

    res.json({

      macAddress,

    });
  } catch (error) {
    console.error('Error getting MAC address:', error);
    res.status(500).json({ message: 'Error getting MAC address' });
  }
});

export default router;
