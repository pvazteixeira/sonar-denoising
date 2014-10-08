function sonarpmodel(N, p_tp, p_tn)
  #p_tp = 0.9;  # probability for a true positive
  #p_tn = 0.99;  # probability for a true negative

  p_o = zeros(N,1);
  p_o[(N-200):end] = 1;

  pr = zeros(N,1);

  for range = 1:1:N
    p_misses = 1;

    if (range>1)
      for i=1:1:(range-1)
        p_misses = p_misses*( (1-p_tn)*p_o[i] + p_tn*(1-p_o[i]) );
      end
    end

    pr[range] = ( p_tp*p_o[range] + (1-p_tp)*(1-p_o[range]) )*p_misses
  end

  return pr
end
