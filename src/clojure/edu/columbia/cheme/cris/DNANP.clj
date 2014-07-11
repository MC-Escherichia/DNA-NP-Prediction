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

(defrecord DNA-NP [core-radius ])

(defn midpoint-of-lens [d r1 r2]
  (/
   (+ (* d d)
      (- (* r2 r2))
      (* r1 r1))
   (* 2 d)))



(defn circle-area [r]
  (* (Math/PI) r r))
(defn contact-radius [d r1 r2]
  "see Wolfram Sphere-Sphere Intersection formula 9"
  (if (> d (+ r1 r2)) 0 (* (/ 1 (* 2 d))
                           (Math/sqrt
                            (- (* 4
                                  (Math/pow d 2)
                                  (Math/pow r1 2))
                               (Math/pow
                                (+ (Math/pow d 2)
                                   (- (Math/pow r2 2))
                                   (Math/pow r1 2))
                                2))))))
(defn contact-area [d [c1 r1] [c2 r2]]
  "calculates area of circle that is common to spheres given by r1 and r2 at distanct d"
  (if (> d  (+ c1 c2))
    (- (circle-area (contact-radius d r1 r2)) ; check for contact orccurs in contact-radius function
       (circle-area (contact-radius d r2 c1))
       (circle-area (contact-radius d r1 c2)))
    ; else
    (Double/NEGATIVE_INFINITY)))

(defn spherical-cap-volume [r x]
  (if (<= 0 x)
      0
      ;else
      (* (/ 1 3)
         (Math/PI)
         (Math/pow x 2)
         (- (* 3 r) x))))

(time  (doall
        (for [r1 (range 1 10)
              r2 (range 1 10)
              c1 (range 1 (- r1 1))
              c2 (range 1 (- r2 1))
              d (range 1 (+ 1 r1 r2))
              :let [[[ca ra] [cb rb]] (sort-by (fn [[c r]] (- (+ c r))) [[c1 r1] [c2 r2]])]
              :when (> rb (- ra d))] (println (contact-area d [ca ra] [cb rb])))))
