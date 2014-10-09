function sonarmmodel(p_o, p)
  # 1-d version of eqn 18 in Moravec's paper
  # p_o is the occupancy probability
  # p probability that the sonar would
  #   detect an occupied cell at the location
  #   (p_tp in the above model)

  N = length(p_o);
  pr = zeros(N,1);
  pr[1] = p_o[1]*p;

  for i=2:1:N
    pr[i] = p_o[i]*p*(1 - sum(pr[1:(i-1)]))
  end

  display(sum(pr))
  return pr
end
