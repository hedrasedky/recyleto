const fetch = require('node-fetch');

async function testLogin() {
    try {
        console.log('🔌 Testing backend login...');

        const response = await fetch('http://10.50.43.118:3000/api/v1/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                email: 'admin@recyleto.com',
                password: 'demo123'
            })
        });

        const data = await response.json();

        if (response.ok) {
            console.log('✅ Login successful!');
            console.log('Token:', data.access_token ? 'Generated' : 'Missing');
            console.log('User:', data.user?.email);
        } else {
            console.log('❌ Login failed:', response.status, data.message);
        }

    } catch (error) {
        console.error('💥 Test error:', error.message);
    }
}

testLogin();
