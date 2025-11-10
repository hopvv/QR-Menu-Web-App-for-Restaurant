import express from 'express';
import mongoose from 'mongoose';
import bodyParser from 'body-parser';
import menuRoutes from './routes/menu';
import adminRoutes from './routes/admin';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use('/api/menu', menuRoutes);
app.use('/api/admin', adminRoutes);

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/qr-menu', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => {
    console.log('Connected to MongoDB');
})
.catch(err => {
    console.error('MongoDB connection error:', err);
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});