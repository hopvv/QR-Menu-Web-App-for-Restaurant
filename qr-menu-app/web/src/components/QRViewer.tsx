import React from 'react';
import QRCode from 'qrcode.react';

const QRViewer: React.FC<{ menuUrl: string }> = ({ menuUrl }) => {
    return (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
            <QRCode value={menuUrl} size={256} />
            <p style={{ textAlign: 'center', marginTop: '20px' }}>
                Scan this QR code to view the menu!
            </p>
        </div>
    );
};

export default QRViewer;