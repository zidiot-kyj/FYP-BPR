function vi = RFrate(u, varargin)

[P,Q,B] = varargin{:};

%% Step : Compute vi according using matrices P and Q

vi = (P(u,:)*Q')'+B;
