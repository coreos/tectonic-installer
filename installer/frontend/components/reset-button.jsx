import React from 'react';

export const ResetButton = () => <button onClick={() => {
  // eslint-disable-next-line no-alert
  (window.config.devMode || window.confirm('Do you really want to start over?')) && window.reset();
}} className="btn btn-link">
   Start Over
</button>;
