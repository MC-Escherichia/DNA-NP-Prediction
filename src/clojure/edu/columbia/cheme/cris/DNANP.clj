(ns edu.columbia.cheme.cris.gavrog
  )


;
;comment  (gen-class
;          :name edu.columbia.cheme.cris.DNANP
;          :prefix-DNANP
;          :extends org.gavrog.joss.pgraphs.basic.Node
;          (:gen-class
;           :constructors {[org.gavrog.joss.pgraphs.basic.UndirectedGraph long]})))

#_(comment  (defn lens-volume [d np1 np2]
            (let [])
            ))


(defn midpoint-of-lens [d r1 r2]
  (/
   (+ (* d d)
      (- (* r2 r2))
      (* r1 r1))
   (* 2 d)))
(defn spherical-cap-volume [r x]
  (if (<= 0 x)
      0
      ;else
      (* (/ 1 3)
         (Math/PI)
         (Math/pow x 2)
         (- (* 3 r) x))))
