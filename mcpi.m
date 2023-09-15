  % Monte Carlo method for estimating pi
  % Generate N random points in a unit square
  function[] =mcpi(N)
  x = rand(N,1); % x coordinates
  y = rand(N,1); % y coordinates
  % Count how many points are inside a unit circle
  inside = 0; % counter
  for i = 1:N % loop over points
    if x(i)^2 + y(i)^2 <= 1 % check if inside circle
        inside = inside + 1; % increment counter
    end
  end
  % Estimate pi as the ratio of points inside circle to total points
  pi_est = 4 * inside / N; % pi estimate
  % Display the result
  fprintf(pi_est);
  end
