import express, { Request, Response } from "express";

import MessageResponse from "../interfaces/MessageResponse";
import emojis from "./emojis";

import printToEpson from "./printToEpson";

const router = express.Router();

router.get<{}, MessageResponse>("/", (req, res) => {
  res.json({
    message: "API - 👋🌎🌍🌏",
  });
});

router.use("/emojis", emojis);

router.use("/print", printToEpson);

export default router;
