import express from "express";
import { Printer, Image } from "@node-escpos/core";
// install escpos-usb adapter module manually
import USB from "@node-escpos/usb-adapter";
// Select the adapter based on your printer type
import { join } from "path";

const router = express.Router();

router.post<{}, any>("/", (req, res) => {
  const { body } = req;
  console.log("body", body);
  const device = new USB();

  device.open(async function (err) {
    if (err) {
      // handle error
      return;
    }

    // encoding is optional

    //encoding should be set to english by default

    const options = { encoding: "UTF-8" /* default */ };

    let printer = new Printer(device, options);

    printer.font("a").text(body.message);

    printer.cut().close();
  });
  res.json({
    message: "Printed",
  });
});

export default router;
