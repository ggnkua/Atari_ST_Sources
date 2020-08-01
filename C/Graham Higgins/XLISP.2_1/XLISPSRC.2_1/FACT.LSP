(defun fact (n)
       (cond ((= n 1) 1)
	     (t (* n (fact (- n 1))))))
