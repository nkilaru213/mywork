const express = require("express");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors({ origin: "http://localhost:5500", credentials: true })); // allow frontend URL
app.use(express.json());

// Mock SSO middleware
function mockSSO(req, res, next) {
  // Replace with real SSO/JWT validation
  const authorized = true;
  if (!authorized) {
    return res.status(401).json({ error: "Unauthorized" });
  }
  next();
}

// Endpoint to return WorkSpaces Reg Code
app.get("/api/getRegCode", mockSSO, (req, res) => {
  const userRegCode = "UNIQUE_REG_CODE_" + Date.now(); // Stubbed
  res.json({ registrationCode: userRegCode });
});

app.listen(PORT, () => {
  console.log(`✅ Backend running at http://localhost:${PORT}`);
});

