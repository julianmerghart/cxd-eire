import React, { useState, useEffect } from 'react';

const ResultsDashboard = () => {
  const [data, setData] = useState({ total_votes: 0, results: { YES: 0, NO: 0 } });
  const [loading, setLoading] = useState(true);

  const fetchResults = async () => {
    try {
      const response = await fetch('https://cxd-eire-1.onrender.com/results');
      const json = await response.json();
      setData(json);
      setLoading(false);
    } catch (error) {
      console.error("Error fetching ledger:", error);
    }
  };

  useEffect(() => {
    fetchResults();
    const interval = setInterval(fetchResults, 5000); // Polling every 5 seconds
    return () => clearInterval(interval);
  }, []);

  if (loading) return <div>Synchronizing with Federation Nodes...</div>;

  const total = data.total_votes || 1; // Prevent division by zero
  const yesPercent = ((data.results.YES / total) * 100).toFixed(1);
  const noPercent = ((data.results.NO / total) * 100).toFixed(1);

  return (
    <div style={{ padding: '20px', maxWidth: '400px', margin: 'auto', fontFamily: 'sans-serif' }}>
      <h2>{data.jurisdiction}</h2>
      <p>Total Verified Votes: <strong>{data.total_votes}</strong></p>
      
      {/* YES BAR */}
      <div style={{ marginBottom: '15px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          <span>YES</span>
          <span>{yesPercent}%</span>
        </div>
        <div style={{ height: '24px', width: '100%', backgroundColor: '#eee', borderRadius: '12px' }}>
          <div style={{ 
            height: '100%', 
            width: `${yesPercent}%`, 
            backgroundColor: '#4CAF50', 
            borderRadius: '12px',
            transition: 'width 0.5s ease-in-out' 
          }} />
        </div>
      </div>

      {/* NO BAR */}
      <div>
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          <span>NO</span>
          <span>{noPercent}%</span>
        </div>
        <div style={{ height: '24px', width: '100%', backgroundColor: '#eee', borderRadius: '12px' }}>
          <div style={{ 
            height: '100%', 
            width: `${noPercent}%`, 
            backgroundColor: '#F44336', 
            borderRadius: '12px',
            transition: 'width 0.5s ease-in-out' 
          }} />
        </div>
      </div>
      
      <p style={{ fontSize: '12px', color: '#666', marginTop: '20px' }}>
        Status: {data.status} | Consensus Verified
      </p>
    </div>
  );
};

export default ResultsDashboard;
