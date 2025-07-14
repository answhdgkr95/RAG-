import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';

describe('Smoke test', () => {
  it('renders a simple message', () => {
    render(<div>Hello, Jest!</div>);
    expect(screen.getByText('Hello, Jest!')).toBeInTheDocument();
  });
});
