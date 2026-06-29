;;; ============================================================
;;; COLDET.lsp — Column Detail Generator for ZCAD / AutoCAD
;;; Version 1.1 — DCL settings dialog
;;; ============================================================

(vl-load-com)

;;; ─── נתיב התוסף (נקבע בזמן טעינה) ──────────────────────────
; ZWCAD עלול להחזיר T מ-findfile במקום נתיב — לכן בודקים stringp
(setq *cdt-lsp-dir*
  (cond
    ; נתיב ידוע לפי USERPROFILE (הכי אמין)
    ((vl-file-directory-p
       (strcat (getenv "USERPROFILE") "\\Desktop\\claude\\Acad\\coldet"))
     (strcat (getenv "USERPROFILE") "\\Desktop\\claude\\Acad\\coldet"))
    ; גיבוי: findfile — רק אם מחזיר מחרוזת
    ((stringp (findfile "COLDET.lsp"))
     (vl-filename-directory (findfile "COLDET.lsp")))
    (t nil)))

;;; ─── המרת מחרוזת למספר שלם (atoi/fix/read לא קיימים ב-ZWCAD) ──
(defun cdt-sint (s / len c1 c2 c3 fl)
  (setq fl (open "C:\\Users\\Owner\\Desktop\\coldet_log.txt" "a"))
  (if fl (progn (write-line (strcat "[SINT] s=" s) fl) (close fl)))
  (setq len (strlen s)
        c1  (- (ascii (substr s 1 1)) 48))
  (setq fl (open "C:\\Users\\Owner\\Desktop\\coldet_log.txt" "a"))
  (if fl (progn (write-line (strcat "[SINT] c1=" (itoa c1)) fl) (close fl)))
  (setq fl (open "C:\\Users\\Owner\\Desktop\\coldet_log.txt" "a"))
  (if fl (progn (write-line "[SINT] pre-if" fl) (close fl)))
  (if (< (strlen s) 2)
    (progn
      (setq fl (open "C:\\Users\\Owner\\Desktop\\coldet_log.txt" "a"))
      (if fl (progn (write-line "[SINT] then-c1" fl) (close fl)))
      c1)
    (if (< (strlen s) 3)
      (+ (* 10 c1) (- (ascii (substr s 2 1)) 48))
      (progn
        (setq c2 (- (ascii (substr s 2 1)) 48)
              c3 (- (ascii (substr s 3 1)) 48))
        (+ (* 100 c1) (* 10 c2) c3)))))

;;; ─── לוג לקובץ ──────────────────────────────────────────────
(setq *cdt-log-path* "C:\\Users\\Owner\\Desktop\\coldet_log.txt")

(defun cdt:log-clear ()
  (setq f (open *cdt-log-path* "w"))
  (if f (progn (write-line "=== COLDET LOG ===" f) (close f))))

(defun cdt:log (msg / f)
  (setq f (open *cdt-log-path* "a"))
  (if f (progn (write-line msg f) (close f)))
  (princ (strcat "\n" msg)))

;;; ─── קבועים ─────────────────────────────────────────────────
(setq CDT:MAX-SPACING 18.0)   ; רווח מקסימלי בין דונאטים
(setq CDT:LEAD-DIST   10.0)   ; מרחק נקודת חיבור ליידר
(setq CDT:HOOK-LEN    10.0)   ; אורך וו אוגן
(setq CDT:HOOK-EXT     3.0)   ; הרחבה ויזואלית של וו (הפרדה)
(setq CDT:DIM-OFFSET  10.0)   ; מרחק קו מידה מהגיאומטריה החיצונית
(setq CDT:BAR-DIM-GAP 15.0)   ; מרווח אנכי של בלוק המוטות מתחת לקו מידת הרוחב

;;; ─── טעינת BARS אוטומטית ────────────────────────────────────
(setq *cdt-bars-ok* nil)
(if (vl-file-directory-p
      (strcat (getenv "USERPROFILE") "\\Desktop\\claude\\Acad\\bars"))
  (if (not (vl-catch-all-error-p
             (vl-catch-all-apply 'load
               (list (strcat (getenv "USERPROFILE")
                             "\\Desktop\\claude\\Acad\\bars\\bars.lsp")))))
    (setq *cdt-bars-ok* T)))

;;; ============================================================
;;; A. הגדרות — שמירה וטעינה
;;; ============================================================

(defun cdt:settings-path ()
  (cond
    ((stringp *cdt-lsp-dir*)
     (strcat *cdt-lsp-dir* "\\coldet_settings.dat"))
    ((stringp (getenv "USERPROFILE"))
     (strcat (getenv "USERPROFILE")
             "\\Desktop\\claude\\Acad\\coldet\\coldet_settings.dat"))
    (t "C:\\Users\\Owner\\Desktop\\claude\\Acad\\coldet\\coldet_settings.dat")))

(defun cdt:defaults ()
  (list
    (cons "version"       "1.1")
    (cons "ext-layer"     "0")
    (cons "int-layer"     "0")
    (cons "int-offset"    "3.0")
    (cons "donut-layer"   "0")
    (cons "dim-layer"     "0")
    (cons "dim-style"     "Standard")
    (cons "dim-scale"     "50.0")
    (cons "title-layer"   "0")
    (cons "title-style1"  "Standard")
    (cons "title-height1" "5.0")
    (cons "title-flip1"   "0")
    (cons "title-style2"  "Standard")
    (cons "title-height2" "2.5")
    (cons "title-flip2"   "0")
    (cons "title-lweight" "25")
    (cons "stirrup-layer"      "0")
    (cons "leader-layer"       "0")
    (cons "ext-color"          "256")
    (cons "int-color"          "256")
    (cons "donut-color"        "256")
    (cons "leader-color"       "256")
    (cons "dim-color"          "256")
    (cons "title-txt1"         "")
    (cons "title-style-num"    "Standard")
    (cons "title-height-num"   "5.0")
    (cons "title-color1"       "256")
    (cons "title-color2"       "256")
    (cons "title-color-num"    "256")
    (cons "title-line-color"   "256")
    (cons "stirrup-color"      "256")
    (cons "stirrup-txt-color"  "256")
    (cons "donut-txt-color"    "256")
    (cons "stirrup-style"      "Standard")
    (cons "stirrup-height"     "2.5")
    (cons "donut-txt-style"    "Standard")
    (cons "donut-txt-height"   "2.5")
    (cons "bar-type"           "1")
    (cons "bar-diameter"       "12")
    (cons "bar-length"         "300")
    (cons "donut-size"         "2.0")
    (cons "leader-len"         "30.0")
    (cons "stirrup-spacing"    "150.0")
))

(defun cdt:save (cfg / f path)
  (setq path (cdt:settings-path))
  (if (setq f (open path "w"))
    (progn
      (foreach p cfg
        (write-line (strcat (car p) "|" (cdr p)) f))
      (close f))
    (princ (strcat "\nError: cannot save to " path "\n"))))

(defun cdt:load (/ path f line pos cfg)
  (setq path (cdt:settings-path))
  (if (setq f (open path "r"))
    (progn
      (setq cfg nil)
      (while (setq line (read-line f))
        (if (setq pos (vl-string-search "|" line))
          (setq cfg (append cfg
                      (list (cons (substr line 1 pos)
                                  (substr line (+ pos 2))))))))
      (close f)
      cfg)
    nil))

(defun cdt:get (cfg key)
  (cdr (assoc key cfg)))

(defun cdt:set! (cfg key val)
  (append (list (cons key val))
          (vl-remove-if (function (lambda (p) (equal (car p) key))) cfg)))

;;; ============================================================
;;; B. כלי הצבעה
;;; ============================================================

(defun cdt:pick-layer (msg / res ent)
  (princ (strcat "\n" msg ": "))
  (setq res (vl-catch-all-apply 'entsel nil))
  (if (vl-catch-all-error-p res) (setq res nil))
  (setq ent (if res (car res) nil))
  (if ent (cdr (assoc 8 (entget ent))) nil))

(defun cdt:pick-or-type-layer (msg-pick msg-type default / choice ent res)
  (initget "Pick Type")
  (setq choice (getkword
    (strcat "\n" msg-pick " [הצבעה/הקלדה] <הצבעה>: ")))
  (cond
    ((or (null choice) (= choice "Pick"))
     (cdt:pick-layer msg-pick))
    (t
     (setq res (getstring (strcat "\n" msg-type " <" default ">: ")))
     (if (= res "") default res))))

(defun cdt:pick-text-height-style (msg / ent ed)
  (princ (strcat "\n" msg ": "))
  (setq ent (car (entsel)))
  (if ent
    (progn
      (setq ed (entget ent))
      (list (cdr (assoc 7 ed))
            (cdr (assoc 40 ed))))
    nil))

(defun cdt:input-or-pick-lweight (msg-pick msg-type / choice ent res)
  (initget "Pick Type")
  (setq choice (getkword
    (strcat "\n" msg-pick " [הצבעה/הקלדה] <הצבעה>: ")))
  (cond
    ((or (null choice) (= choice "Pick"))
     (progn
       (princ (strcat "\n" msg-pick ": "))
       (setq ent (car (entsel)))
       (if ent (cdr (assoc 370 (entget ent))) 25)))
    (t
     (setq res (getreal (strcat "\n" msg-type ": ")))
     (if res (fix (* res 100)) 25))))

;;; ============================================================
;;; C. כלי מתמטיקה
;;; ============================================================

(defun cdt:dist2d (p1 p2)
  (sqrt (+ (expt (- (car p2)  (car p1))  2)
           (expt (- (cadr p2) (cadr p1)) 2))))

(defun cdt:lerp (p1 p2 tp)
  (list (+ (car p1)  (* tp (- (car p2)  (car p1))))
        (+ (cadr p1) (* tp (- (cadr p2) (cadr p1))))))

(defun cdt:ceiling-int (x)
  ; עיגול למעלה לשלם
  (if (= x (fix x)) (fix x) (1+ (fix x))))

;;; ============================================================
;;; D. קריאת XData (DCOL / COLNAM)
;;; ============================================================

(defun cdt:read-colnum (ename / xd applist count result)
  (regapp "DCOL")
  (setq xd (cdr (assoc -3 (entget ename '("DCOL")))))
  (if xd
    (progn
      (setq applist (cdr (car xd))  count 0  result nil)
      (foreach item applist
        (if (= (car item) 1000)
          (progn
            (setq count (1+ count))
            (if (= count 2) (setq result (cdr item))))))
      result)
    nil))

;;; ============================================================
;;; E. זיהוי צורה
;;; ============================================================

(defun cdt:get-poly-verts (ename / ed etype verts sub sed)
  (setq ed (entget ename)
        etype (cdr (assoc 0 ed))
        verts nil)
  (if (= etype "LWPOLYLINE")
    ; LWPOLYLINE: group 10 נמצא ישירות ב-entget
    (foreach pair ed
      (if (= (car pair) 10)
        (setq verts (append verts (list (cdr pair))))))
    ; POLYLINE (ישן): גולש על תת-אובייקטי VERTEX
    (progn
      (setq sub (entnext ename))
      (while (and sub
                  (not (equal (cdr (assoc 0 (setq sed (entget sub)))) "SEQEND")))
        (if (equal (cdr (assoc 0 sed)) "VERTEX")
          (setq verts (append verts (list (cdr (assoc 10 sed))))))
        (setq sub (entnext sub)))))
  verts)

(defun cdt:detect-shape (ename / etype verts n p0 pn)
  (setq etype (cdr (assoc 0 (entget ename))))
  (cond
    ((= etype "CIRCLE") "circle")
    ((or (= etype "LWPOLYLINE") (= etype "POLYLINE"))
     (setq verts (cdt:get-poly-verts ename)
           n     (length verts))
     ; הסר vertex סגירה כפול (polyline שהנקודה האחרונה = הראשונה)
     (if (and (> n 1)
              (setq p0 (car verts) pn (last verts))
              (< (distance (list (car p0) (cadr p0))
                           (list (car pn) (cadr pn))) 1e-4))
       (setq n (1- n)))
     (cond
       ((= n 4) "rect")
       ((= n 6) "lshape")
       (t nil)))
    (t nil)))

;;; ============================================================
;;; F. כלי מלבן
;;; ============================================================

(defun cdt:bbox-from-verts (verts / xs ys)
  ; מחזיר (minX minY maxX maxY)
  (setq xs (mapcar 'car  verts)
        ys (mapcar 'cadr verts))
  (list (apply 'min xs) (apply 'min ys)
        (apply 'max xs) (apply 'max ys)))

(defun cdt:bbox-inset (bb d)
  ; מצמצם bbox ב-d מכל צד
  (list (+ (car bb)   d) (+ (cadr bb)  d)
        (- (caddr bb) d) (- (cadddr bb) d)))

(defun cdt:bbox-corners (bb)
  ; מחזיר (BL BR TR TL)
  (list
    (list (car bb)   (cadr bb))    ; BL
    (list (caddr bb) (cadr bb))    ; BR
    (list (caddr bb) (cadddr bb))  ; TR
    (list (car bb)   (cadddr bb))));TL

(defun cdt:bbox-center (bb)
  (list (* 0.5 (+ (car bb) (caddr bb)))
        (* 0.5 (+ (cadr bb) (cadddr bb)))))

(defun cdt:bbox-width  (bb) (- (caddr bb)  (car bb)))
(defun cdt:bbox-height (bb) (- (cadddr bb) (cadr bb)))

;;; ============================================================
;;; G. פונקציות ציור בסיסיות
;;; ============================================================

(defun cdt:set-layer (ename layer)
  (entmod (subst (cons 8 layer) (assoc 8 (entget ename)) (entget ename)))
  ename)

(defun cdt:draw-closed-rect (bb layer / prev)
  (cdt:ensure-layer layer)
  (setq prev (getvar "CLAYER"))
  (setvar "CLAYER" layer)
  (command "_.PLINE"
    (list (car bb)   (cadr bb))
    (list (caddr bb) (cadr bb))
    (list (caddr bb) (cadddr bb))
    (list (car bb)   (cadddr bb))
    (list (car bb)   (cadr bb))
    "")
  (setvar "CLAYER" prev)
  (entlast))

(defun cdt:draw-line (p1 p2 layer / prev)
  (cdt:ensure-layer layer)
  (setq prev (getvar "CLAYER"))
  (setvar "CLAYER" layer)
  (command "_.LINE" p1 p2 "")
  (setvar "CLAYER" prev)
  (entlast))

(defun cdt:draw-donut (center size layer / prev)
  (cdt:ensure-layer layer)
  (setq prev (getvar "CLAYER"))
  (setvar "CLAYER" layer)
  (command "_.DONUT" 0 size center "")
  (setvar "CLAYER" prev)
  (entlast))

(defun cdt:draw-text-center (pt height style txt layer angle mirror / ename use-style base-list)
  (cdt:ensure-layer layer)
  (setq use-style
    (if (and style (stringp style) (not (equal style "")) (tblsearch "STYLE" style))
      style
      "Standard"))
  (setq base-list
    (list (cons 0  "TEXT")
          (cons 8  layer)
          (cons 10 (list (car pt) (cadr pt) 0.0))
          (cons 40 height)
          (cons 1  txt)
          (cons 50 (* angle (/ pi 180.0)))
          (cons 7  use-style)
          (cons 72 1)
          (cons 11 (list (car pt) (cadr pt) 0.0))))
  (entmake (if mirror (append base-list (list (cons 71 2))) base-list))
  (entlast))

;;; ============================================================
;;; H. דונאטים — מלבן
;;; ============================================================

(defun cdt:corner-toward-center (corner center inset)
  (list
    (if (< (car corner)  (car center))
        (+ (car corner)  inset)
        (- (car corner)  inset))
    (if (< (cadr corner) (cadr center))
        (+ (cadr corner) inset)
        (- (cadr corner) inset))))

;;; ============================================================
;;; H.2. דונאטים עם מעקב מיקומים — ללא כפילות
;;; ============================================================

(defun cdt:pt-near-p (pt lst / found)
  (setq found nil)
  (foreach p lst
    (if (and (< (abs (- (car p)  (car pt)))  0.01)
             (< (abs (- (cadr p) (cadr pt))) 0.01))
      (setq found T)))
  found)

(defun cdt:donut-if-new (center size layer placed)
  (if (not (cdt:pt-near-p center placed))
    (progn
      (cdt:draw-donut center size layer)
      (append placed (list center)))
    placed))

(defun cdt:fill-pts (p1 p2 size layer placed / dist n i tp pos)
  (setq dist (sqrt (+ (expt (- (car p2) (car p1)) 2)
                      (expt (- (cadr p2) (cadr p1)) 2)))
        n    (- (cdt:ceiling-int (/ dist CDT:MAX-SPACING)) 1))
  (if (> n 0)
    (progn
      (setq i 1)
      (while (<= i n)
        (setq tp    (/ (* 1.0 i) (+ n 1))
              pos   (cdt:lerp p1 p2 tp)
              placed (cdt:donut-if-new pos size layer placed))
        (setq i (1+ i)))))
  placed)

(defun cdt:donut-inset (size bb / raw max-inset)
  ; inset רגיל = 1.2*size (פער שפת-דונאט-לקו = 0.7*size), אבל לא יותר ממחצית הצלע
  ; הקטנה ביותר של bb — כדי שדונאט בעמוד קטן לא "יעבור" את המרכז לצד השני
  (setq raw      (* 1.2 size)
        max-inset (* 0.5 (cdt:bbox-width  bb)))
  (if (< (* 0.5 (cdt:bbox-height bb)) max-inset)
    (setq max-inset (* 0.5 (cdt:bbox-height bb))))
  (if (> raw max-inset) max-inset raw))

(defun cdt:place-corner-donuts-tracked (bb-int size layer placed / corners center pos inset)
  (setq inset   (cdt:donut-inset size bb-int)
        corners (cdt:bbox-corners bb-int)
        center  (cdt:bbox-center  bb-int))
  (foreach c corners
    (setq pos    (cdt:corner-toward-center c center inset)
          placed (cdt:donut-if-new pos size layer placed)))
  placed)

(defun cdt:place-edge-donuts-tracked (bb-int size layer placed /
                                       corners bl br tr tl inset
                                       avail-h avail-w nh nw i tp ep pos)
  (setq inset (cdt:donut-inset size bb-int)
        corners (cdt:bbox-corners bb-int)
        bl (nth 0 corners)  br (nth 1 corners)
        tr (nth 2 corners)  tl (nth 3 corners))
  (setq avail-h (- (cdt:bbox-height bb-int) (* 2.0 inset))
        nh      (- (cdt:ceiling-int (/ avail-h CDT:MAX-SPACING)) 1)
        avail-w (- (cdt:bbox-width  bb-int) (* 2.0 inset))
        nw      (- (cdt:ceiling-int (/ avail-w CDT:MAX-SPACING)) 1))
  (if (> nh 0)
    (progn
      (setq i 1)
      (while (<= i nh)
        (setq tp (/ (* 1.0 i) (+ nh 1)))
        (setq ep  (cdt:lerp (list (car bl) (+ (cadr bl) inset))
                            (list (car tl) (- (cadr tl) inset)) tp)
              pos (list (+ (car ep) inset) (cadr ep))
              placed (cdt:donut-if-new pos size layer placed))
        (setq ep  (cdt:lerp (list (car br) (+ (cadr br) inset))
                            (list (car tr) (- (cadr tr) inset)) tp)
              pos (list (- (car ep) inset) (cadr ep))
              placed (cdt:donut-if-new pos size layer placed))
        (setq i (1+ i)))))
  (if (> nw 0)
    (progn
      (setq i 1)
      (while (<= i nw)
        (setq tp (/ (* 1.0 i) (+ nw 1)))
        (setq ep  (cdt:lerp (list (+ (car bl) inset) (cadr bl))
                            (list (- (car br) inset) (cadr br)) tp)
              pos (list (car ep) (+ (cadr ep) inset))
              placed (cdt:donut-if-new pos size layer placed))
        (setq ep  (cdt:lerp (list (+ (car tl) inset) (cadr tl))
                            (list (- (car tr) inset) (cadr tr)) tp)
              pos (list (car ep) (- (cadr ep) inset))
              placed (cdt:donut-if-new pos size layer placed))
        (setq i (1+ i)))))
  placed)

;;; ============================================================
;;; H.3. זיהוי וחלוקת צורת ר לשני בלוקים
;;; ============================================================

(defun cdt:lshape-missing-corner (verts / bb tol corners mc found)
  (setq bb (cdt:bbox-from-verts verts)  tol 1e-4  mc nil
        corners (list
          (list (car bb)   (cadr bb))
          (list (caddr bb) (cadr bb))
          (list (caddr bb) (cadddr bb))
          (list (car bb)   (cadddr bb))))
  (foreach c corners
    (setq found nil)
    (foreach v verts
      (if (and (< (abs (- (car v)  (car c)))  tol)
               (< (abs (- (cadr v) (cadr c))) tol))
        (setq found T)))
    (if (not found) (setq mc c)))
  mc)

(defun cdt:lshape-concave-vertex (verts / bb tol cv)
  (setq bb (cdt:bbox-from-verts verts)  tol 1e-4  cv nil)
  (foreach v verts
    (if (and (> (car v)  (+ (car bb)   tol))
             (< (car v)  (- (caddr bb) tol))
             (> (cadr v) (+ (cadr bb)  tol))
             (< (cadr v) (- (cadddr bb) tol)))
      (setq cv v)))
  cv)

(defun cdt:lshape-bboxes (verts / bb mc cv cx cy x0 y0 x1 y1 r1 r2 a1 a2)
  (setq bb (cdt:bbox-from-verts verts)
        mc (cdt:lshape-missing-corner verts)
        cv (cdt:lshape-concave-vertex verts)
        cx (car cv)   cy (cadr cv)
        x0 (car bb)   y0 (cadr bb)
        x1 (caddr bb) y1 (cadddr bb))
  (cond
    ((and (< (abs (- (car mc) x0)) 1e-4) (< (abs (- (cadr mc) y0)) 1e-4))
     (setq r1 (list x0 cy x1 y1)  r2 (list cx y0 x1 cy)))
    ((and (< (abs (- (car mc) x1)) 1e-4) (< (abs (- (cadr mc) y0)) 1e-4))
     (setq r1 (list x0 cy x1 y1)  r2 (list x0 y0 cx cy)))
    ((and (< (abs (- (car mc) x1)) 1e-4) (< (abs (- (cadr mc) y1)) 1e-4))
     (setq r1 (list x0 y0 x1 cy)  r2 (list x0 cy cx y1)))
    (t
     (setq r1 (list x0 y0 x1 cy)  r2 (list cx cy x1 y1))))
  (setq a1 (* (cdt:bbox-width r1) (cdt:bbox-height r1))
        a2 (* (cdt:bbox-width r2) (cdt:bbox-height r2)))
  (if (>= a1 a2) (list r1 r2) (list r2 r1)))

;;; ============================================================
;;; J. צורה סמלית — אוגן
;;; ============================================================

(defun cdt:draw-stirrup-rect (bb-int stirrup-layer txt-style txt-height line-color txt-color /
                               x0 y0 x1 y1
                               he lx
                               p1 p2 p3 p4 p5 p6 p7
                               ename txt-h txt-w th sty prev-lay)
  (setq x0 (car   bb-int)  y0 (cadr   bb-int)
        x1 (caddr bb-int)  y1 (cadddr bb-int)
        he CDT:HOOK-EXT    lx CDT:HOOK-LEN
        th  (if (and txt-height (> txt-height 0)) txt-height 2.5)
        sty (if (and txt-style  (not (equal txt-style ""))) txt-style "Standard"))

  (setq p1 (list (- x1 lx)  (+ y1 he))
        p2 (list x1          (+ y1 he))
        p3 (list x1          y0)
        p4 (list x0          y0)
        p5 (list x0          y1)
        p6 (list (+ x1 he)   y1)
        p7 (list (+ x1 he)   (- y1 lx)))

  (cdt:log "[S1] ensure-layer")
  (cdt:ensure-layer stirrup-layer)
  (cdt:log "[S2] calling cdt:color-str")
  (setq *_sc (cdt:color-str line-color))
  (cdt:log (strcat "[S2a] color-str=" *_sc))
  (cdt:log "[S2b] set color")
  (command "_.COLOR" *_sc)
  (cdt:log "[S2d] color-done")
  (setq prev-lay (getvar "CLAYER"))
  (setvar "CLAYER" stirrup-layer)
  (cdt:log "[S3] PLINE")
  (command "_.PLINE" p1 p2 p3 p4 p5 p6 p7 "")
  (cdt:log "[S4] after PLINE")
  (setvar "CLAYER" prev-lay)
  (command "_.COLOR" "BYLAYER")

  (cdt:log "[S5] txt-h")
  (command "_.COLOR" (cdt:color-str txt-color))
  (setq txt-h (rtos (- y1 y0) 2 0))
  (cdt:log "[S6] text-center H")
  (cdt:draw-text-center (list (- x0 2.0) (* 0.5 (+ y0 y1))) th sty txt-h stirrup-layer 90 nil)
  (setq txt-w (rtos (- x1 x0) 2 0))
  (cdt:log "[S7] text-center W")
  (cdt:draw-text-center (list (* 0.5 (+ x0 x1)) (- y0 1.0 th)) th sty txt-w stirrup-layer 0 nil)
  (cdt:log "[S8] done")
  (command "_.COLOR" "BYLAYER"))

;;; ============================================================
;;; K. כותרת
;;; ============================================================

(defun cdt:create-title (col-num scale-str cfg top-y cx /
                          h1 h2 hn lw layer style1 style2 style-num
                          col1 col2 col-num-clr col-line
                          gap y2 yl y1
                          half-w x0 x1 txt1 txt2 sep-line flip1
                          tb-heb tb-num w-heb w-num gap-btw cx-heb cx-num)
  (setq h1          (atof (cdt:get cfg "title-height1"))
        h2          (atof (cdt:get cfg "title-height2"))
        hn          (if (and (cdt:get cfg "title-height-num")
                             (> (atof (cdt:get cfg "title-height-num")) 0.0))
                      (atof (cdt:get cfg "title-height-num"))
                      h1)
        lw          (cdt-sint (cdt:get cfg "title-lweight"))
        layer       (cdt:get cfg "title-layer")
        style1      (cdt:get cfg "title-style1")
        style2      (cdt:get cfg "title-style2")
        style-num   (if (and (cdt:get cfg "title-style-num")
                             (not (equal (cdt:get cfg "title-style-num") "")))
                      (cdt:get cfg "title-style-num")
                      style1)
        col1        (cdt:color-str (cdt:get cfg "title-color1"))
        col2        (cdt:color-str (cdt:get cfg "title-color2"))
        col-num-clr (cdt:color-str (cdt:get cfg "title-color-num"))
        col-line    (cdt:color-str (cdt:get cfg "title-line-color"))
        flip1       (equal (cdt:get cfg "title-flip1") "1")
        txt1        (cdt:str-or-empty (cdt:get cfg "title-txt1")))

  (setq gap    (* 0.25 h1)
        y2     (+ top-y h1 (* 0.5 h2))
        yl     (+ top-y h1 h2 (* 2.0 gap))
        y1     (+ yl gap (* 0.5 h1))
        half-w (+ (* 5.0 h1) (* 0.5 h1))
        x0     (- cx half-w)
        x1     (+ cx half-w))

  ; שורה 1 — טקסט עברי (מהגדרות) + מספר עמוד, זה לצד זה
  (setq tb-heb (vl-catch-all-apply 'textbox
                 (list (list (cons 0 "TEXT") (cons 1 txt1) (cons 40 h1) (cons 7 style1)))))
  ; רוחב עברי — הגדול מבין textbox להערכה לפי תווים (textbox מזלזל בעברית)
  (setq w-heb
    (max
      (if (and tb-heb (not (vl-catch-all-error-p tb-heb)) (listp tb-heb) (listp (cadr tb-heb)))
        (car (cadr tb-heb))
        0.0)
      (* (strlen txt1) h1 0.6)))
  (setq tb-num (vl-catch-all-apply 'textbox
                 (list (list (cons 0 "TEXT") (cons 1 col-num) (cons 40 hn) (cons 7 style-num)))))
  (setq w-num
    (if (and tb-num (not (vl-catch-all-error-p tb-num)) (listp tb-num) (listp (cadr tb-num)))
      (car (cadr tb-num))
      (* (strlen col-num) hn 0.6)))
  ; מיקום: מספר משמאל, עברית מימין (קריאה RTL)
  ; מרווח = 3 תווים בסיס + תו נוסף לכל ספרה מעבר לראשונה (יותר מקום למספר רב-ספרתי)
  (setq gap-btw (* (/ w-num (* 1.0 (max 1 (strlen col-num))))
                   (+ 3.0 (- (max 1 (strlen col-num)) 1)))
        cx-num  (- cx (* 0.5 (+ w-heb gap-btw)))
        cx-heb  (+ cx (* 0.5 (+ w-num gap-btw))))
  ; אם אין טקסט עברי — מספר במרכז
  (if (equal txt1 "")
    (setq cx-num cx)
    (progn
      (setvar "CECOLOR" col1)
      (cdt:draw-text-center (list cx-heb y1) h1 style1 txt1 layer 0 flip1)
      (setvar "CECOLOR" "256")))
  (setvar "CECOLOR" col-num-clr)
  (cdt:draw-text-center (list cx-num y1) hn style-num col-num layer 0 nil)
  (setvar "CECOLOR" "256")

  ; קו מפריד
  (setvar "CECOLOR" col-line)
  (setq sep-line (cdt:draw-line (list x0 yl) (list x1 yl) layer))
  (setvar "CECOLOR" "256")
  (if (assoc 370 (entget sep-line))
    (entmod (subst (cons 370 lw) (assoc 370 (entget sep-line)) (entget sep-line)))
    (entmod (append (entget sep-line) (list (cons 370 lw)))))

  ; שורה 2 — קנ"מ, ללא flip (מספרים תמיד LTR)
  (setvar "CECOLOR" col2)
  (setq txt2 (strcat "1:" scale-str))
  (cdt:draw-text-center (list cx y2) h2 style2 txt2 layer 0 nil)
  (setvar "CECOLOR" "256"))

;;; ============================================================
;;; L. חלון הגדרות — DCL Dialog
;;; ============================================================

(defun cdt:lsp-dir () *cdt-lsp-dir*)

(defun cdt:str-or-empty (v) (if (stringp v) v ""))

(defun cdt:ensure-layer (name)
  (if (and name (stringp name) (not (equal name ""))
           (not (tblsearch "LAYER" name)))
    (command "_.LAYER" "N" name "")))

(defun cdt:color-str (v)
  (if (and v (stringp v) (not (equal v ""))) v "256"))

(defun cdt:pick-color (tile-key / c)
  (setq c (acad_colordlg (cdt-sint (cdt:color-str (get_tile tile-key))) nil))
  (if c (set_tile tile-key (itoa c))))

; קורא צבע נראה לעין: אם ByLayer — קורא מהשכבה
(defun cdt:ent-color (ed / col lr)
  (setq col (if (assoc 62 ed) (cdr (assoc 62 ed)) 256))
  (if (= col 256)
    (progn
      (setq lr (tblsearch "LAYER" (cdr (assoc 8 ed))))
      (if (and lr (assoc 62 lr))
        (setq col (abs (cdr (assoc 62 lr)))))))
  (if (or (null col) (< col 1) (> col 255)) (setq col 256))
  (itoa col))

(setq *cdt-color-vals* '("256" "1" "2" "3" "4" "5" "6" "7" "8" "9"))
(setq *cdt-color-disp* '("ByLayer" "1-Red" "2-Yellow" "3-Green" "4-Cyan" "5-Blue" "6-Magenta" "7-White" "8" "9"))

; --- קבלת רשימות מהסרטוט ---

(defun cdt:get-all-layers (/ result tblent)
  (setq result nil  tblent (tblnext "LAYER" T))
  (while tblent
    (if (stringp (cdr (assoc 2 tblent)))
      (setq result (append result (list (cdr (assoc 2 tblent))))))
    (setq tblent (tblnext "LAYER")))
  (if result result (list "0")))

(defun cdt:get-all-dimstyles (/ result tblent)
  (setq result nil  tblent (tblnext "DIMSTYLE" T))
  (while tblent
    (if (stringp (cdr (assoc 2 tblent)))
      (setq result (append result (list (cdr (assoc 2 tblent))))))
    (setq tblent (tblnext "DIMSTYLE")))
  (if result result (list "Standard")))

(defun cdt:get-all-txtstyles (/ result tblent)
  (setq result nil  tblent (tblnext "STYLE" T))
  (while tblent
    (if (stringp (cdr (assoc 2 tblent)))
      (setq result (append result (list (cdr (assoc 2 tblent))))))
    (setq tblent (tblnext "STYLE")))
  (if result result (list "Standard")))

; --- עזרים ל-popup_list ---

(defun cdt:list-index (lst val / i result)
  (setq i 0  result 0)
  (foreach item lst
    (if (equal item val) (setq result i))
    (setq i (1+ i)))
  result)

(defun cdt:fill-popup (key items)
  (start_list key)
  (foreach item items (add_list item))
  (end_list))

(defun cdt:set-popup (key items value)
  (set_tile key (itoa (cdt:list-index items value))))

(defun cdt:get-popup (key items / idx)
  (setq idx (cdt-sint (cdt:str-or-empty (get_tile key))))
  (if (and items (>= idx 0) (< idx (length items)))
    (nth idx items)
    ""))

; --- כתיבה וקריאה של ערכי הדיאלוג ---

(defun cdt:dialog-write (cfg / ll sl)
  (setq ll (cdt:get-all-layers)
        sl (cdt:get-all-txtstyles)
        *cdt-layer-list* ll
        *cdt-style-list* sl)
  ; מילוי רשימות
  (cdt:fill-popup "ext_layer"     ll)  (cdt:fill-popup "int_layer"     ll)
  (cdt:fill-popup "donut_layer"   ll)  (cdt:fill-popup "dim_layer"     ll)
  (cdt:fill-popup "title_layer1"  ll)  (cdt:fill-popup "title_layer2"  ll)
  (cdt:fill-popup "stirrup_layer" ll)
  (cdt:fill-popup "leader_layer"  ll)
  (cdt:fill-popup "dim_style"        sl)
  (cdt:fill-popup "stir_style"       sl)
  (cdt:fill-popup "donut_txt_style"  sl)
  (cdt:fill-popup "title_style1" sl)  (cdt:fill-popup "title_style2"  sl)
  (cdt:fill-popup "title_style_num" sl)
  ; בחירה נוכחית — שכבות
  (cdt:set-popup "ext_layer"     ll (cdt:get cfg "ext-layer"))
  (cdt:set-popup "int_layer"     ll (cdt:get cfg "int-layer"))
  (cdt:set-popup "donut_layer"   ll (cdt:get cfg "donut-layer"))
  (cdt:set-popup "dim_layer"     ll (cdt:get cfg "dim-layer"))
  (cdt:set-popup "title_layer1"  ll (cdt:get cfg "title-layer1"))
  (cdt:set-popup "title_layer2"  ll (cdt:get cfg "title-layer2"))
  (cdt:set-popup "stirrup_layer"  ll (cdt:get cfg "stirrup-layer"))
  (cdt:set-popup "leader_layer"   ll (cdt:get cfg "leader-layer"))
  ; בחירה נוכחית — סגנונות
  (cdt:set-popup "dim_style"        sl (cdt:get cfg "dim-style"))
  (cdt:set-popup "stir_style"       sl (cdt:get cfg "stirrup-style"))
  (cdt:set-popup "donut_txt_style"  sl (cdt:get cfg "donut-txt-style"))
  (cdt:set-popup "title_style1"     sl (cdt:get cfg "title-style1"))
  (cdt:set-popup "title_style2"     sl (cdt:get cfg "title-style2"))
  (cdt:set-popup "title_style_num"  sl (cdt:get cfg "title-style-num"))
  ; צבעים — edit_box
  (set_tile "ext_color"        (cdt:color-str (cdt:get cfg "ext-color")))
  (set_tile "int_color"        (cdt:color-str (cdt:get cfg "int-color")))
  (set_tile "donut_color"      (cdt:color-str (cdt:get cfg "donut-color")))
  (set_tile "leader_color"     (cdt:color-str (cdt:get cfg "leader-color")))
  (set_tile "title_color1"     (cdt:color-str (cdt:get cfg "title-color1")))
  (set_tile "title_color2"     (cdt:color-str (cdt:get cfg "title-color2")))
  (set_tile "title_color_num"  (cdt:color-str (cdt:get cfg "title-color-num")))
  (set_tile "stirrup_color"    (cdt:color-str (cdt:get cfg "stirrup-color")))
  (set_tile "stir_txt_col"     (cdt:color-str (cdt:get cfg "stirrup-txt-color")))
  (set_tile "donut_txt_col"    (cdt:color-str (cdt:get cfg "donut-txt-color")))
  ; שדות edit_box
  (set_tile "int_offset"    (cdt:str-or-empty (cdt:get cfg "int-offset")))
  (set_tile "donut_size"    (cdt:str-or-empty (cdt:get cfg "donut-size")))
  (set_tile "bar_len"       (cdt:str-or-empty (cdt:get cfg "bar-length")))
  (set_tile "stir_height"        (cdt:str-or-empty (cdt:get cfg "stirrup-height")))
  (set_tile "donut_txt_height"   (cdt:str-or-empty (cdt:get cfg "donut-txt-height")))
  (set_tile "dim_scale"          (rtos (getvar "DIMSCALE") 2 0))
  (set_tile "title_height1"      (cdt:str-or-empty (cdt:get cfg "title-height1")))
  (set_tile "title_height2"      (cdt:str-or-empty (cdt:get cfg "title-height2")))
  (set_tile "title_flip1"        (cdt:str-or-empty (cdt:get cfg "title-flip1")))
  (set_tile "title_flip2"        (cdt:str-or-empty (cdt:get cfg "title-flip2")))
  (set_tile "title_height_num"   (cdt:str-or-empty (cdt:get cfg "title-height-num")))
  (set_tile "title_txt1"         (cdt:str-or-empty (cdt:get cfg "title-txt1"))))

(defun cdt:dialog-read (cfg)
  ; שכבות
  (setq cfg (cdt:set! cfg "ext-layer"     (cdt:get-popup "ext_layer"     *cdt-layer-list*)))
  (setq cfg (cdt:set! cfg "int-layer"     (cdt:get-popup "int_layer"     *cdt-layer-list*)))
  (setq cfg (cdt:set! cfg "donut-layer"   (cdt:get-popup "donut_layer"   *cdt-layer-list*)))
  (setq cfg (cdt:set! cfg "dim-layer"     (cdt:get-popup "dim_layer"     *cdt-layer-list*)))
  (setq cfg (cdt:set! cfg "title-layer1"  (cdt:get-popup "title_layer1"  *cdt-layer-list*)))
  (setq cfg (cdt:set! cfg "title-layer2"  (cdt:get-popup "title_layer2"  *cdt-layer-list*)))
  (setq cfg (cdt:set! cfg "stirrup-layer" (cdt:get-popup "stirrup_layer" *cdt-layer-list*)))
  (setq cfg (cdt:set! cfg "leader-layer"  (cdt:get-popup "leader_layer"  *cdt-layer-list*)))
  ; סגנונות
  (setq cfg (cdt:set! cfg "dim-style"      (cdt:get-popup "dim_style"       *cdt-style-list*)))
  (setq cfg (cdt:set! cfg "stirrup-style"  (cdt:get-popup "stir_style"      *cdt-style-list*)))
  (setq cfg (cdt:set! cfg "donut-txt-style" (cdt:get-popup "donut_txt_style" *cdt-style-list*)))
  ; צבעים — קריאה מ-edit_box
  (setq cfg (cdt:set! cfg "ext-color"          (cdt:color-str (get_tile "ext_color"))))
  (setq cfg (cdt:set! cfg "int-color"          (cdt:color-str (get_tile "int_color"))))
  (setq cfg (cdt:set! cfg "donut-color"        (cdt:color-str (get_tile "donut_color"))))
  (setq cfg (cdt:set! cfg "leader-color"       (cdt:color-str (get_tile "leader_color"))))
  (setq cfg (cdt:set! cfg "title-color1"       (cdt:color-str (get_tile "title_color1"))))
  (setq cfg (cdt:set! cfg "title-color2"       (cdt:color-str (get_tile "title_color2"))))
  (setq cfg (cdt:set! cfg "stirrup-color"      (cdt:color-str (get_tile "stirrup_color"))))
  (setq cfg (cdt:set! cfg "stirrup-txt-color"  (cdt:color-str (get_tile "stir_txt_col"))))
  (setq cfg (cdt:set! cfg "donut-txt-color"    (cdt:color-str (get_tile "donut_txt_col"))))
  ; שדות edit_box
  (setq cfg (cdt:set! cfg "int-offset"       (get_tile "int_offset")))
  (setq cfg (cdt:set! cfg "donut-size"       (get_tile "donut_size")))
  (setq cfg (cdt:set! cfg "bar-length"       (get_tile "bar_len")))
  (setq cfg (cdt:set! cfg "stirrup-height"    (get_tile "stir_height")))
  (setq cfg (cdt:set! cfg "donut-txt-height"  (get_tile "donut_txt_height")))
  (setq cfg (cdt:set! cfg "dim-scale"         (get_tile "dim_scale")))
  (setq cfg (cdt:set! cfg "title-style1"     (cdt:get-popup "title_style1"     *cdt-style-list*)))
  (setq cfg (cdt:set! cfg "title-style2"     (cdt:get-popup "title_style2"     *cdt-style-list*)))
  (setq cfg (cdt:set! cfg "title-style-num"  (cdt:get-popup "title_style_num"  *cdt-style-list*)))
  (setq cfg (cdt:set! cfg "title-height1"    (get_tile "title_height1")))
  (setq cfg (cdt:set! cfg "title-height2"    (get_tile "title_height2")))
  (setq cfg (cdt:set! cfg "title-height-num" (get_tile "title_height_num")))
  (setq cfg (cdt:set! cfg "title-flip1"      (get_tile "title_flip1")))
  (setq cfg (cdt:set! cfg "title-flip2"      (get_tile "title_flip2")))
  (setq cfg (cdt:set! cfg "title-color-num"  (cdt:color-str (get_tile "title_color_num"))))
  (setq cfg (cdt:set! cfg "title-txt1"       (get_tile "title_txt1")))
  cfg)

;;; פותח תיבת bar_data מתוך dlg-id קיים, מחזיר cfg עם leader-text מעודכן
(defun cdt:bar-leader-dialog (dlg-id cfg /
                               qt-list dm-list type-res diam-res len-res)
  (setq qt-list (list "1" "2" "3" "4")
        dm-list (list "6" "8" "10" "12" "14" "16" "18" "20"
                      "22" "24" "26" "28" "30" "32" "34" "36" "38" "40"))
  (setq *cdt-bar-ok* nil)
  (if (new_dialog "bar_data" dlg-id)
    (progn
      (cdt:fill-popup "bar_type" qt-list)
      (cdt:fill-popup "bar_diam" dm-list)
      (cdt:set-popup  "bar_type" qt-list (cdt:get cfg "bar-type"))
      (cdt:set-popup  "bar_diam" dm-list (cdt:get cfg "bar-diameter"))
      (set_tile "bar_len" (cdt:str-or-empty (cdt:get cfg "bar-length")))
      (action_tile "bd_ok"
        "(setq *cdt-bar-ok* T *cdt-bd-type* (get_tile \"bar_type\") *cdt-bd-diam* (get_tile \"bar_diam\") *cdt-bd-len* (get_tile \"bar_len\"))(done_dialog 0)")
      (action_tile "bd_cancel" "(done_dialog 0)")
      (start_dialog)
      (if *cdt-bar-ok*
        (progn
          (setq type-res (nth (cdt-sint *cdt-bd-type*) qt-list)
                diam-res (nth (cdt-sint *cdt-bd-diam*) dm-list)
                len-res  *cdt-bd-len*)
          (setq cfg (cdt:set! cfg "bar-type"     type-res))
          (setq cfg (cdt:set! cfg "bar-diameter" diam-res))
          (setq cfg (cdt:set! cfg "bar-length"   len-res))
          (setq cfg (cdt:set! cfg "leader-text"
                      (strcat (cdt:bar-opher type-res) diam-res " L=" len-res)))))))
  cfg)

(defun cdt:settings-dialog (cfg-in / dlg-id done ldir res ent ed old-dimstyle)
  (setq *cdt-dlg-vals*  cfg-in
        *cdt-pick-code* nil
        *cdt-dialog-ok* nil
        done            nil)

  (setq *cdt-layers*    (cdt:get-all-layers))
  (setq *cdt-dimstyles* (cdt:get-all-dimstyles))
  (setq *cdt-txtstyles* (cdt:get-all-txtstyles))

  (setq dlg-id (load_dialog "COLDET"))
  (if (or (null dlg-id) (not (numberp dlg-id)) (< dlg-id 0))
    (progn
      (setq ldir (cdt:lsp-dir))
      (if ldir
        (setq dlg-id (load_dialog (strcat ldir "\\COLDET.dcl"))))))

  (if (or (null dlg-id) (not (numberp dlg-id)) (< dlg-id 0))
    (princ "\nError: COLDET.dcl not found - check coldet folder.\n")

    (progn
      (while (not done)
        (if (not (new_dialog "coldet_settings" dlg-id))
          (setq done T)
          (progn
            (cdt:dialog-write *cdt-dlg-vals*)
            (setq *cdt-pick-code* nil)

            ; --- כפתורי OK / Cancel ---
            (action_tile "dlg_ok"
              "(setq *cdt-pick-code* 1 *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 0)")
            (action_tile "dlg_cancel"
              "(setq *cdt-pick-code* 0)(done_dialog 0)")

            ; --- כפתורי Pick — שומרים מצב לפני סגירה ---
            (action_tile "btn_ext"
              "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(setq *cdt-pick-code* 2)(done_dialog 0)")
            (action_tile "btn_int"
              "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(setq *cdt-pick-code* 3)(done_dialog 0)")
            (action_tile "btn_dlay"
              "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(setq *cdt-pick-code* 4)(done_dialog 0)")
            (action_tile "btn_dim"
              "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(setq *cdt-pick-code* 7)(done_dialog 0)")
            (action_tile "btn_tlay1"
              "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(setq *cdt-pick-code* 8)(done_dialog 0)")
            (action_tile "btn_tlay2"
              "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(setq *cdt-pick-code* 9)(done_dialog 0)")
            (action_tile "btn_leader"
              "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(setq *cdt-pick-code* 5)(done_dialog 0)")
            (action_tile "btn_stir"
              "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(setq *cdt-pick-code* 12)(done_dialog 0)")
            (action_tile "btn_ststy"
              "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(setq *cdt-pick-code* 13)(done_dialog 0)")
            (action_tile "btn_dtxt"
              "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(setq *cdt-pick-code* 15)(done_dialog 0)")


            ; --- כפתורי Color — פותח acad_colordlg ללא סגירת הדיאלוג ---
            (action_tile "btn_ext_col"    "(cdt:pick-color \"ext_color\")")
            (action_tile "btn_int_col"    "(cdt:pick-color \"int_color\")")
            (action_tile "btn_donut_col"  "(cdt:pick-color \"donut_color\")")
            (action_tile "btn_ldr_col"    "(cdt:pick-color \"leader_color\")")
            (action_tile "btn_tc1_col"    "(cdt:pick-color \"title_color1\")")
            (action_tile "btn_tc2_col"    "(cdt:pick-color \"title_color2\")")
            (action_tile "btn_tcn_col"    "(cdt:pick-color \"title_color_num\")")
            (action_tile "btn_stc_col"    "(cdt:pick-color \"stirrup_color\")")
            (action_tile "btn_stxt_col"   "(cdt:pick-color \"stir_txt_col\")")
            (action_tile "btn_dtxt_col"   "(cdt:pick-color \"donut_txt_col\")")

            (start_dialog)

            (cond

              ; ביטול (Cancel, ESC, X)
              ((or (null *cdt-pick-code*) (equal *cdt-pick-code* 0))
               (setq done T))

              ; אישור OK — ערכים נקראו כבר ב-action_tile לפני done_dialog
              ((equal *cdt-pick-code* 1)
               (cdt:save *cdt-dlg-vals*)
               (princ "\nSettings saved.")
               (setq *cdt-dialog-ok* T  done T))

              ; Pick: גיאומטריה חיצונית
              ((equal *cdt-pick-code* 2)
               (princ "\nPick external geometry line: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "ext-layer" (cdr (assoc 8 ed))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "ext-color" (cdt:ent-color ed))))))

              ; Pick: גיאומטריה פנימית
              ((equal *cdt-pick-code* 3)
               (princ "\nPick internal geometry line: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "int-layer" (cdr (assoc 8 ed))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "int-color" (cdt:ent-color ed))))))

              ; Pick: דונאט — שכבה + גודל + צבע; מעתיק שכבה+צבע ללידר אוטומטית
              ((equal *cdt-pick-code* 4)
               (princ "\nPick Donut: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "donut-layer" (cdr (assoc 8 ed))))
                   (if (assoc 40 ed)
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "donut-size"
                       (rtos (* 2.0 (cdr (assoc 40 ed))) 2 4))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "donut-color" (cdt:ent-color ed))))))

              ; Pick: לידר — שכבה + צבע + אורך
              ((equal *cdt-pick-code* 5)
               (princ "\nPick leader line: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "leader-layer" (cdr (assoc 8 ed))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "leader-color" (cdt:ent-color ed)))
                   (if (and (assoc 10 ed) (assoc 11 ed))
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "leader-len"
                       (rtos (distance (cdr (assoc 10 ed)) (cdr (assoc 11 ed))) 2 4)))))))

              ; Pick: מידה — שכבה + סגנון + DIMSCALE + צבע
              ((equal *cdt-pick-code* 7)
               (princ "\nPick existing dimension: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "dim-layer" (cdr (assoc 8 ed))))
                   (if (and (assoc 3 ed)
                            (not (equal (cdr (assoc 3 ed)) ""))
                            (tblsearch "DIMSTYLE" (cdr (assoc 3 ed))))
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "dim-style" (cdr (assoc 3 ed)))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "dim-scale"
                     (rtos (getvar "DIMSCALE") 2 4))))))

              ; Pick: כותרת עליונה — שכבה + סגנון + גובה + צבע
              ((equal *cdt-pick-code* 8)
               (princ "\nPick upper title entity: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "title-layer1" (cdr (assoc 8 ed))))
                   (if (assoc 7 ed)
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "title-style1" (cdr (assoc 7 ed)))))
                   (if (assoc 40 ed)
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "title-height1" (rtos (cdr (assoc 40 ed)) 2 4))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "title-color1"
                     (cdt:ent-color ed))))))

              ; Pick: כותרת תחתונה — שכבה + סגנון + גובה + צבע
              ((equal *cdt-pick-code* 9)
               (princ "\nPick lower title entity: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "title-layer2" (cdr (assoc 8 ed))))
                   (if (assoc 7 ed)
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "title-style2" (cdr (assoc 7 ed)))))
                   (if (assoc 40 ed)
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "title-height2" (rtos (cdr (assoc 40 ed)) 2 4))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "title-color2"
                     (cdt:ent-color ed))))))

              ; Pick: שכבת אוגן
              ((equal *cdt-pick-code* 12)
               (princ "\nPick stirrup layer entity: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "stirrup-layer" (cdr (assoc 8 ed))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "stirrup-color" (cdt:ent-color ed))))))

              ; Pick: סגנון טקסט אוגן
              ((equal *cdt-pick-code* 13)
               (princ "\nPick text for stirrup style: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (if (assoc 7 ed)
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "stirrup-style" (cdr (assoc 7 ed)))))
                   (if (assoc 40 ed)
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "stirrup-height" (rtos (cdr (assoc 40 ed)) 2 4))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "stirrup-txt-color" (cdt:ent-color ed))))))

              ; Pick: סגנון טקסט דונאט
              ((equal *cdt-pick-code* 15)
               (princ "\nPick text for donut style: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (if (assoc 7 ed)
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "donut-txt-style" (cdr (assoc 7 ed)))))
                   (if (assoc 40 ed)
                     (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "donut-txt-height" (rtos (cdr (assoc 40 ed)) 2 4))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "donut-txt-color" (cdt:ent-color ed))))))


))))

      (unload_dialog dlg-id)))

  (if *cdt-dialog-ok* *cdt-dlg-vals* cfg-in))

(defun cdt:merge-cfg (saved defaults / result key)
  ; מחזיר את saved, ומוסיף כל שדה חסר מ-defaults
  (setq result saved)
  (foreach pair defaults
    (setq key (car pair))
    (if (null (cdt:get result key))
      (setq result (cdt:set! result key (cdr pair)))))
  result)

(defun cdt:first-run (/ saved merged)
  (setq saved (cdt:load))
  (if saved
    (progn
      (setq merged (cdt:merge-cfg saved (cdt:defaults)))
      (cdt:save merged)
      merged)
    (progn
      (princ "\nDefault settings loaded. Type S for settings.")
      (cdt:save (cdt:defaults))
      (cdt:defaults))))

;;; ============================================================
;;; M.0. עזרים לבלוק מוטות
;;; ============================================================

(defun cdt:label-stirrup-safe (bb layer txt-style txt-height txt-color)
  ; קריאה ישירה ללא vl-catch-all-apply — כדי שהדיאלוג יקבל פוקוס חלון תקין
  (if *cdt-bars-ok*
    (bars:label-stirrup bb layer txt-style txt-height txt-color)))

(defun cdt:bar-opher (type-str)
  (cond ((= type-str "1") "%%156")
        ((= type-str "2") "%%157")
        ((= type-str "3") "%%158")
        (t                "%%159")))

(defun cdt:dist2d-sq (p1 p2)
  (+ (expt (- (car p2) (car p1)) 2) (expt (- (cadr p2) (cadr p1)) 2)))

(defun cdt:closest-and-farthest-donut (placed pt / d-near d-far dd-near dd-far dd)
  ; מחזיר (הדונאט הקרוב ביותר ל-pt, הדונאט הרחוק ביותר ממנו) — זוג אלכסוני
  (setq d-near nil d-far nil dd-near nil dd-far nil)
  (foreach p placed
    (setq dd (cdt:dist2d-sq p pt))
    (if (or (null dd-near) (< dd dd-near)) (setq d-near p dd-near dd))
    (if (or (null dd-far) (> dd dd-far)) (setq d-far p dd-far dd)))
  (list d-near d-far))

(defun cdt:draw-bar-block (d1 d2 conn-pt qty bar-char bar-diam bar-len donut-radius layer line-color txt-style txt-height txt-color /
                              txt cx ext-bottom top-y txt-h gap line-y dx dy dist edge1 edge2 near-pt
                              tb txt-w half-len use-style)
  ; conn-pt = (cx, ext-bottom)
  (setq txt (strcat (itoa qty) bar-char bar-diam
                    (if (and (stringp bar-len) (> (strlen bar-len) 0)
                             (not (equal bar-len "0")))
                      (strcat " L=" bar-len) ""))
        cx         (car  conn-pt)
        ext-bottom (cadr conn-pt)
        txt-h      (if (and txt-height (> txt-height 0.0)) txt-height 2.5)
        gap        1.0
        top-y      (- ext-bottom txt-h)
        line-y     (- top-y txt-h gap))
  (setq use-style
    (cond
      ((and txt-style (not (equal txt-style "")) (tblsearch "STYLE" txt-style)) txt-style)
      ((tblsearch "STYLE" "OPHER") "OPHER")
      (t "Standard")))
  (setq tb (vl-catch-all-apply 'textbox
              (list (list (cons 0 "TEXT") (cons 1 txt) (cons 40 txt-h)
                          (cons 7 use-style)))))
  (setq txt-w
    (if (and tb (not (vl-catch-all-error-p tb)) (listp tb) (listp (cadr tb)))
      (car (cadr tb))
      (* (strlen txt) txt-h 0.6)))
  (setq half-len (+ (* 0.5 txt-w) 2.5)
        near-pt  (list (- cx half-len) line-y))
  (setq edge1
    (if d1
      (progn
        (setq dx (- (car near-pt) (car d1)) dy (- (cadr near-pt) (cadr d1))
              dist (sqrt (+ (* dx dx) (* dy dy))))
        (if (> dist donut-radius)
          (list (+ (car d1)  (* dx (/ donut-radius dist)))
                (+ (cadr d1) (* dy (/ donut-radius dist))))
          near-pt))
      nil))
  (setq edge2
    (if d2
      (progn
        (setq dx (- (car near-pt) (car d2)) dy (- (cadr near-pt) (cadr d2))
              dist (sqrt (+ (* dx dx) (* dy dy))))
        (if (> dist donut-radius)
          (list (+ (car d2)  (* dx (/ donut-radius dist)))
                (+ (cadr d2) (* dy (/ donut-radius dist))))
          near-pt))
      nil))
  (if *cdt-bars-ok* (bars:ensure-opher-style))
  (command "_.COLOR" (if (and line-color (not (equal line-color ""))) line-color "BYLAYER"))
  (cdt:draw-line near-pt (list (+ cx half-len) line-y) layer)
  (entmake
    (list (cons 0  "TEXT")
          (cons 8  layer)
          (cons 62 (if (and txt-color (not (equal txt-color ""))) (cdt-sint txt-color) 256))
          (cons 10 (list cx top-y 0.0))
          (cons 40 txt-h)
          (cons 1  txt)
          (cons 50 0.0)
          (cons 7  use-style)
          (cons 72 1)
          (cons 73 3)
          (cons 11 (list cx top-y 0.0))))
  (if edge1 (cdt:draw-line edge1 near-pt layer))
  (if edge2 (cdt:draw-line edge2 near-pt layer))
  (command "_.COLOR" "BYLAYER"))

(defun cdt:bar-popup-dialog (cfg / dlg-id qt-list dm-list)
  (setq *cdt-bar-ok* nil
        qt-list (list "1" "2" "3" "4")
        dm-list (list "6" "8" "10" "12" "14" "16" "18" "20"
                      "22" "24" "26" "28" "30" "32" "34" "36" "38" "40"))
  (setq dlg-id (load_dialog "COLDET"))
  (if (or (null dlg-id) (not (numberp dlg-id)) (< dlg-id 0))
    (if (cdt:lsp-dir)
      (setq dlg-id (load_dialog (strcat (cdt:lsp-dir) "\\COLDET.dcl")))))
  (if (or (null dlg-id) (not (numberp dlg-id)) (< dlg-id 0))
    cfg
    (progn
      (if (not (new_dialog "bar_data" dlg-id))
        (progn (unload_dialog dlg-id) cfg)
        (progn
          (cdt:fill-popup "bar_type" qt-list)
          (cdt:fill-popup "bar_diam" dm-list)
          (cdt:set-popup  "bar_type" qt-list (cdt:get cfg "bar-type"))
          (cdt:set-popup  "bar_diam" dm-list (cdt:get cfg "bar-diameter"))
          (set_tile "bar_len" (cdt:str-or-empty (cdt:get cfg "bar-length")))
          (action_tile "bd_ok"
            "(setq *cdt-bar-ok* T *cdt-bd-type* (get_tile \"bar_type\") *cdt-bd-diam* (get_tile \"bar_diam\") *cdt-bd-len* (get_tile \"bar_len\"))(done_dialog 0)")
          (action_tile "bd_cancel" "(done_dialog 0)")
          (start_dialog)
          (if *cdt-bar-ok*
            (progn
              (setq cfg (cdt:set! cfg "bar-type"
                          (nth (cdt-sint *cdt-bd-type*) qt-list)))
              (setq cfg (cdt:set! cfg "bar-diameter"
                          (nth (cdt-sint *cdt-bd-diam*) dm-list)))
              (setq cfg (cdt:set! cfg "bar-length" *cdt-bd-len*))
              (cdt:save cfg)))
          (unload_dialog dlg-id)
          cfg)))))

;;; ============================================================
;;; M. הפקודה הראשית — C:COLDET
;;; ============================================================

(defun C:COLDET (/ cfg sel ename col-num shape
                   verts bb-ext bb-int offset
                   donut-size donut-layer
                   top-y cx
                   use-xdata col-input scale-str
                   stir-w stir-h stir-x0 stir-y0 stir-bb
                   ls-bbs ls-bb1 ls-bb2 ls-int1 ls-int2 ls-donut1 ls-donut2
                   ls-overall ls-placed
                   ls-sx0 ls-sy1 ls-sbb1 ls-sx0-2 ls-sy2 ls-sbb2
                   ls-mc ls-cv ls-cvx ls-cvy ls-x0 ls-y0 ls-x1 ls-y1
                   notch-top notch-right
                   h-yref h-yoff v-xref v-xoff
                   ls-ov-x0 ls-ov-y0 ls-ov-x1 ls-ov-y1 ls-ov
                   ls-ov-inset ls-ov-cen ls-ov-bl ls-ov-br ls-ov-tr ls-ov-tl
                   ls-arm1 ls-arm2
                   ls-a1-inset ls-a1-cen ls-a1-pb ls-a1-pt
                   ls-a2-inset ls-a2-cen ls-a2-pl ls-a2-pr
                   placed bar-conn-pt
                   bar-d1 bar-d2
                   prev-dimscale dim-off dim-prev-lay
                   prev-osmode
                   ent-before blk-ss blk-e blk-name blk-base ins-pt
                   dlg-start ldir start-code cfg-saved shape-kw)
  (vl-load-com)
  (cdt:log-clear)
  (cdt:log (strcat "COLDET start [v-bar-color] sint=" (if cdt-sint "OK" "NIL")))

  ;; טעינת הגדרות
  (setq cfg-saved (cdt:load))
  (setq cfg (cdt:merge-cfg cfg-saved (cdt:defaults)))

  ;; תפריט פתיחה — DCL
  (setq start-code nil)
  (setq dlg-start (load_dialog "COLDET"))
  (if (or (null dlg-start) (not (numberp dlg-start)) (< dlg-start 0))
    (progn
      (setq ldir (cdt:lsp-dir))
      (if ldir (setq dlg-start (load_dialog (strcat ldir "\\COLDET.dcl"))))))
  (if (and (numberp dlg-start) (>= dlg-start 0)
           (new_dialog "coldet_start" dlg-start))
    (progn
      (action_tile "start_settings" "(progn (setq *cdt-start-code* 1) (done_dialog 0))")
      (action_tile "start_run"      "(progn (setq *cdt-start-code* 2) (done_dialog 0))")
      (action_tile "start_cancel"   "(progn (setq *cdt-start-code* 0) (done_dialog 0))")
      (setq *cdt-start-code* nil)
      (start_dialog)
      (unload_dialog dlg-start)
      (setq start-code *cdt-start-code*))
    (setq start-code 2))

  (cond
    ;; הגדרות
    ((equal start-code 1)
     (setq cfg (cdt:settings-dialog cfg)))

    ;; ביטול
    ((equal start-code 0)
     (princ "\nCancelled."))

    ;; הרץ — פתח הגדרות רק בהרצה ראשונה (אין קובץ הגדרות שמור)
    (t
     (if (null cfg-saved)
       (setq cfg (cdt:settings-dialog cfg)))

     ;; בחירת סוג צורה ידנית — לפני בחירת הפוליגון
     (initget "REC L T Z U CIR")
     (setq shape-kw (getkword "\nShape type [REC/L/T/Z/U/CIR] <REC>: "))
     (if (null shape-kw) (setq shape-kw "REC"))   ; Enter = ריבוע
     (setq shape (cond ((= shape-kw "REC") "rect")
                       ((= shape-kw "L")   "lshape")
                       ((= shape-kw "T")   "tshape")
                       ((= shape-kw "Z")   "zshape")
                       ((= shape-kw "U")   "chet")
                       ((= shape-kw "CIR") "circle")))
     (cdt:log (strcat "[L01] shape=" shape " (kw=" shape-kw ")"))

     ;; צורות שעדיין לא מומשו — הודעה מסודרת ויציאה נקייה
     (if (member shape '("tshape" "zshape" "chet"))
       (progn (princ (strcat "\n[" shape-kw " - not yet implemented]")) (exit)))

     (setq sel (entsel "\nSelect column outline: "))
     (if (null sel)
       (princ "\nCancelled.")
       (progn
         (setq ename (car sel))

         ;; קריאת XData
         (setq col-num (cdt:read-colnum ename))

         ;; נתוני הגדרות נפוצים
         (setq offset      (atof (cdt:get cfg "int-offset"))
               donut-size  (atof (cdt:get cfg "donut-size"))
               donut-layer (cdt:get cfg "donut-layer"))

         ;; שמירת אובייקט אחרון לפני ציור (לאיסוף לבלוק)
         (setq ent-before (entlast))

         ;; כיבוי OSNAP — מונע הצמדה לגיאומטריה קיימת בזמן ציור הפנימית
         (setq prev-osmode (getvar "OSMODE"))
         (setvar "OSMODE" 0)

         ;; ─── מסלול מלבן ───────────────────────────────────────
         (if (= shape "rect")
           (progn
             (setq verts  (cdt:get-poly-verts ename)
                   bb-ext (cdt:bbox-from-verts verts)
                   bb-int (cdt:bbox-inset bb-ext offset))

             ;; גיאומטריה חיצונית
             (cdt:log "[L02] ext-rect")
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "ext-color")))
             (cdt:draw-closed-rect bb-ext (cdt:get cfg "ext-layer"))
             (setvar "CECOLOR" "256")

             ;; קווי מידות לגיאומטריה חיצונית
             (cdt:log "[L03] dim-lines")
             (setq prev-dimscale (getvar "DIMSCALE")
                   dim-off       CDT:DIM-OFFSET
                   dim-prev-lay  (getvar "CLAYER"))
             (cdt:ensure-layer (cdt:get cfg "dim-layer"))
             (setvar "CLAYER"   (cdt:get cfg "dim-layer"))
             (setvar "CECOLOR"  (cdt:color-str (cdt:get cfg "dim-color")))
             (setvar "DIMSCALE" (atof (cdt:get cfg "dim-scale")))
             (if (and (cdt:get cfg "dim-style")
                      (not (equal (cdt:get cfg "dim-style") "")))
               (if (tblsearch "DIMSTYLE" (cdt:get cfg "dim-style"))
                 (command "_.DIMSTYLE" "R" (cdt:get cfg "dim-style") "")
                 (princ (strcat "\nWarning: dim-style '" (cdt:get cfg "dim-style") "' not found."))))
             (command "_.DIMLINEAR"
               (list (car bb-ext)   (cadr bb-ext))
               (list (caddr bb-ext) (cadr bb-ext))
               (list (* 0.5 (+ (car bb-ext) (caddr bb-ext)))
                     (- (cadr bb-ext) dim-off)))
             (command "_.DIMLINEAR"
               (list (car bb-ext) (cadr  bb-ext))
               (list (car bb-ext) (cadddr bb-ext))
               (list (- (car bb-ext) dim-off)
                     (* 0.5 (+ (cadr bb-ext) (cadddr bb-ext)))))
             (setvar "CLAYER"   dim-prev-lay)
             (setvar "CECOLOR"  "256")
             (setvar "DIMSCALE" prev-dimscale)

             ;; גיאומטריה פנימית
             (cdt:log "[L04] int-rect")
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "int-color")))
             (cdt:draw-closed-rect bb-int (cdt:get cfg "int-layer"))
             (setvar "CECOLOR" "256")

             ;; דונאטים (tracked לספירה)
             (cdt:log "[L05] corner-donuts")
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "donut-color")))
             (setq placed nil)
             (setq placed (cdt:place-corner-donuts-tracked bb-int donut-size donut-layer placed))
             (cdt:log "[L06] edge-donuts")
             (setq placed (cdt:place-edge-donuts-tracked   bb-int donut-size donut-layer placed))
             (cdt:log (strcat "[L07] donuts-done placed=" (itoa (length placed))))
             (setvar "CECOLOR" "256")

             ;; צורה סמלית — ממוקמת מימין לחתך החיצוני
             (setq stir-w  (cdt:bbox-width  bb-int)
                   stir-h  (cdt:bbox-height bb-int)
                   stir-x0 (+ (caddr bb-ext) 15.0)
                   stir-y0 (+ (cadr  bb-ext)
                               (* 0.5 (- (cdt:bbox-height bb-ext) stir-h)))
                   stir-bb (list stir-x0 stir-y0
                                 (+ stir-x0 stir-w)
                                 (+ stir-y0 stir-h)))
             (cdt:log "[L08] stirrup-rect")
             (cdt:draw-stirrup-rect stir-bb (cdt:get cfg "stirrup-layer")
               (cdt:get cfg "stirrup-style")
               (atof (cdt:get cfg "stirrup-height"))
               (cdt:get cfg "stirrup-color")
               (cdt:get cfg "stirrup-txt-color"))
             (cdt:log "[L09] after stirrup-rect")

             ;; BARS — תווית אוגן
             (cdt:log "[L10] bars-label")
             (if *cdt-bars-ok*
               (cdt:label-stirrup-safe stir-bb (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-txt-color")))

             ;; נקודת חיבור לבלוק מוטות — תחתית-ממורכז, מתחת לקו מידת הרוחב
             ;; (אותו צד כמו המידות; החישוקים מימין → אין התנגשות לפי בנייה)
             ;; זוג הדונאטים התחתונים (שמאל+ימין) → לידרים יורדים סימטרית למרכז
             (cdt:log "[L11] bar-conn-pt")
             (setq bar-conn-pt (list (* 0.5 (+ (car bb-ext) (caddr bb-ext)))
                                     (- (cadr bb-ext) CDT:DIM-OFFSET CDT:BAR-DIM-GAP))
                   bar-d1 (car (cdt:closest-and-farthest-donut placed
                                 (list (car  bb-int) (cadr bb-int))))
                   bar-d2 (car (cdt:closest-and-farthest-donut placed
                                 (list (caddr bb-int) (cadr bb-int)))))

             ;; Y עליון ומרכז X לכותרת
             (setq top-y (cadddr bb-ext)
                   cx    (* 0.5 (+ (car bb-ext) (caddr bb-ext))))))

         ;; ─── מסלול עיגול ──────────────────────────────────────
         (if (= shape "circle")
           (progn
             (princ "\n[Circle - not yet implemented]")
             (setq top-y 0  cx 0)))

         ;; ─── מסלול צורת ר ─────────────────────────────────────
         (if (= shape "lshape")
           (progn
             (cdt:log "[L20] lshape-path")
             (setq verts (cdt:get-poly-verts ename))
             (if (null (cdt:lshape-concave-vertex verts))
               (progn (setvar "OSMODE" prev-osmode) (princ "\nError: L-shape column not recognized.") (exit)))

             (setq ls-overall (cdt:bbox-from-verts verts)
                   ls-mc      (cdt:lshape-missing-corner verts)
                   ls-cv      (cdt:lshape-concave-vertex verts))
             (setq ls-cvx (car  ls-cv)   ls-cvy (cadr ls-cv)
                   ls-x0  (car  ls-overall)   ls-y0  (cadr  ls-overall)
                   ls-x1  (caddr ls-overall)  ls-y1  (cadddr ls-overall))
             (setq notch-top   (> (cadr ls-mc) ls-cvy)
                   notch-right (> (car  ls-mc) ls-cvx))
             ;; 2 מלבנים חופפים לציור ולחישוקים — כל אחד לאורך כל הזרוע
             (setq ls-int1
               (if notch-top
                 (list (+ ls-x0 offset) (+ ls-y0 offset) (- ls-x1 offset) (- ls-cvy offset))
                 (list (+ ls-x0 offset) (+ ls-cvy offset) (- ls-x1 offset) (- ls-y1 offset)))
                   ls-int2
               (if notch-right
                 (list (+ ls-x0 offset) (+ ls-y0 offset) (- ls-cvx offset) (- ls-y1 offset))
                 (list (+ ls-cvx offset) (+ ls-y0 offset) (- ls-x1 offset) (- ls-y1 offset))))
             ;; 2 מלבנים לא-חופפים לדונאטים — פינות על גבול אמיתי
             (setq ls-bbs    (cdt:lshape-bboxes verts)
                   ls-bb1    (car  ls-bbs)
                   ls-bb2    (cadr ls-bbs)
                   ls-donut1 (cdt:bbox-inset ls-bb1 offset)
                   ls-donut2 (cdt:bbox-inset ls-bb2 offset))

             ;; קו חיצוני — העתק הצורה המקורית
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "ext-color")))
             (command "_.COPY" (ssadd ename (ssadd)) "" '(0 0 0) '(0 0 0))
             (cdt:set-layer (entlast) (cdt:get cfg "ext-layer"))
             (setvar "CECOLOR" "256")

             ;; קווי מידות לגיאומטריה חיצונית
             (setq prev-dimscale (getvar "DIMSCALE")
                   dim-off       CDT:DIM-OFFSET
                   dim-prev-lay  (getvar "CLAYER"))
             (cdt:ensure-layer (cdt:get cfg "dim-layer"))
             (setvar "CLAYER"   (cdt:get cfg "dim-layer"))
             (setvar "CECOLOR"  (cdt:color-str (cdt:get cfg "dim-color")))
             (setvar "DIMSCALE" (atof (cdt:get cfg "dim-scale")))
             (if (and (cdt:get cfg "dim-style")
                      (not (equal (cdt:get cfg "dim-style") "")))
               (if (tblsearch "DIMSTYLE" (cdt:get cfg "dim-style"))
                 (command "_.DIMSTYLE" "R" (cdt:get cfg "dim-style") "")
                 (princ (strcat "\nWarning: dim-style '" (cdt:get cfg "dim-style") "' not found."))))
             ;; מחרוזות מידות — תמיד בצד המגרעת
             ;; מחרוזת אופקית (2 קווים על הצלע האופקית של המגרעת)
             (setq h-yref (if notch-top ls-y1 ls-y0)
                   h-yoff (if notch-top (+ ls-y1 dim-off) (- ls-y0 dim-off)))
             (command "_.DIMLINEAR"
               (list ls-x0  h-yref)
               (list ls-cvx h-yref)
               (list (* 0.5 (+ ls-x0 ls-cvx)) h-yoff))
             (command "_.DIMLINEAR"
               (list ls-cvx h-yref)
               (list ls-x1  h-yref)
               (list (* 0.5 (+ ls-cvx ls-x1)) h-yoff))
             ;; מחרוזת אנכית (2 קווים על הצלע האנכית של המגרעת)
             (setq v-xref (if notch-right ls-x1 ls-x0)
                   v-xoff (if notch-right (+ ls-x1 dim-off) (- ls-x0 dim-off)))
             (command "_.DIMLINEAR"
               (list v-xref ls-y0)
               (list v-xref ls-cvy)
               (list v-xoff (* 0.5 (+ ls-y0 ls-cvy))))
             (command "_.DIMLINEAR"
               (list v-xref ls-cvy)
               (list v-xref ls-y1)
               (list v-xoff (* 0.5 (+ ls-cvy ls-y1))))
             (setvar "CLAYER"   dim-prev-lay)
             (setvar "CECOLOR"  "256")
             (setvar "DIMSCALE" prev-dimscale)

             ;; גיאומטריות פנימיות
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "int-color")))
             (cdt:draw-closed-rect ls-int1 (cdt:get cfg "int-layer"))
             (cdt:draw-closed-rect ls-int2 (cdt:get cfg "int-layer"))
             (setvar "CECOLOR" "256")

             ;; דונאטים — L-shape: חפיפה + זרועות
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "donut-color")))
             (setq ls-placed nil)
             ;; מרובע חפיפה של שתי הזרועות
             (setq ls-ov-x0 (max (car  ls-int1) (car  ls-int2))
                   ls-ov-y0 (max (cadr ls-int1) (cadr ls-int2))
                   ls-ov-x1 (min (caddr ls-int1) (caddr ls-int2))
                   ls-ov-y1 (min (cadddr ls-int1) (cadddr ls-int2))
                   ls-ov    (list ls-ov-x0 ls-ov-y0 ls-ov-x1 ls-ov-y1))
             ;; 4 פינות מרובע החפיפה
             (setq ls-placed (cdt:place-corner-donuts-tracked ls-ov donut-size donut-layer ls-placed))
             ;; מיקומי הפינות אחרי inset — לשימוש במילוי הצלעות
             (setq ls-ov-inset (cdt:donut-inset donut-size ls-ov)
                   ls-ov-cen   (cdt:bbox-center ls-ov)
                   ls-ov-bl    (cdt:corner-toward-center (list ls-ov-x0 ls-ov-y0) ls-ov-cen ls-ov-inset)
                   ls-ov-br    (cdt:corner-toward-center (list ls-ov-x1 ls-ov-y0) ls-ov-cen ls-ov-inset)
                   ls-ov-tr    (cdt:corner-toward-center (list ls-ov-x1 ls-ov-y1) ls-ov-cen ls-ov-inset)
                   ls-ov-tl    (cdt:corner-toward-center (list ls-ov-x0 ls-ov-y1) ls-ov-cen ls-ov-inset))
             ;; מילוי 2 צלעות חיצוניות של החפיפה
             (if notch-right
               (setq ls-placed (cdt:fill-pts ls-ov-bl ls-ov-tl donut-size donut-layer ls-placed))
               (setq ls-placed (cdt:fill-pts ls-ov-br ls-ov-tr donut-size donut-layer ls-placed)))
             (if notch-top
               (setq ls-placed (cdt:fill-pts ls-ov-bl ls-ov-br donut-size donut-layer ls-placed))
               (setq ls-placed (cdt:fill-pts ls-ov-tl ls-ov-tr donut-size donut-layer ls-placed)))
             ;; זרוע 1 — הרחבה אופקית (בכיוון notch-right)
             (setq ls-arm1
               (if notch-right
                 (list ls-ov-x1 (cadr ls-int1) (caddr ls-int1) (cadddr ls-int1))
                 (list (car ls-int1) (cadr ls-int1) ls-ov-x0 (cadddr ls-int1))))
             (setq ls-a1-inset (cdt:donut-inset donut-size ls-arm1)
                   ls-a1-cen   (cdt:bbox-center ls-arm1))
             (if notch-right
               (setq ls-a1-pb (cdt:corner-toward-center (list (caddr ls-arm1) (cadr  ls-arm1)) ls-a1-cen ls-a1-inset)
                     ls-a1-pt (cdt:corner-toward-center (list (caddr ls-arm1) (cadddr ls-arm1)) ls-a1-cen ls-a1-inset))
               (setq ls-a1-pb (cdt:corner-toward-center (list (car ls-arm1) (cadr  ls-arm1)) ls-a1-cen ls-a1-inset)
                     ls-a1-pt (cdt:corner-toward-center (list (car ls-arm1) (cadddr ls-arm1)) ls-a1-cen ls-a1-inset)))
             (setq ls-placed (cdt:donut-if-new ls-a1-pb donut-size donut-layer ls-placed))
             (setq ls-placed (cdt:donut-if-new ls-a1-pt donut-size donut-layer ls-placed))
             (if notch-right
               (progn
                 (setq ls-placed (cdt:fill-pts ls-ov-br ls-a1-pb donut-size donut-layer ls-placed))
                 (setq ls-placed (cdt:fill-pts ls-ov-tr ls-a1-pt donut-size donut-layer ls-placed)))
               (progn
                 (setq ls-placed (cdt:fill-pts ls-ov-bl ls-a1-pb donut-size donut-layer ls-placed))
                 (setq ls-placed (cdt:fill-pts ls-ov-tl ls-a1-pt donut-size donut-layer ls-placed))))
             (setq ls-placed (cdt:fill-pts ls-a1-pb ls-a1-pt donut-size donut-layer ls-placed))
             ;; זרוע 2 — הרחבה אנכית (בכיוון notch-top)
             (setq ls-arm2
               (if notch-top
                 (list (car ls-int2) ls-ov-y1 (caddr ls-int2) (cadddr ls-int2))
                 (list (car ls-int2) (cadr ls-int2) (caddr ls-int2) ls-ov-y0)))
             (setq ls-a2-inset (cdt:donut-inset donut-size ls-arm2)
                   ls-a2-cen   (cdt:bbox-center ls-arm2))
             (if notch-top
               (setq ls-a2-pl (cdt:corner-toward-center (list (car  ls-arm2) (cadddr ls-arm2)) ls-a2-cen ls-a2-inset)
                     ls-a2-pr (cdt:corner-toward-center (list (caddr ls-arm2) (cadddr ls-arm2)) ls-a2-cen ls-a2-inset))
               (setq ls-a2-pl (cdt:corner-toward-center (list (car  ls-arm2) (cadr ls-arm2)) ls-a2-cen ls-a2-inset)
                     ls-a2-pr (cdt:corner-toward-center (list (caddr ls-arm2) (cadr ls-arm2)) ls-a2-cen ls-a2-inset)))
             (setq ls-placed (cdt:donut-if-new ls-a2-pl donut-size donut-layer ls-placed))
             (setq ls-placed (cdt:donut-if-new ls-a2-pr donut-size donut-layer ls-placed))
             (if notch-top
               (progn
                 (setq ls-placed (cdt:fill-pts ls-ov-tl ls-a2-pl donut-size donut-layer ls-placed))
                 (setq ls-placed (cdt:fill-pts ls-ov-tr ls-a2-pr donut-size donut-layer ls-placed)))
               (progn
                 (setq ls-placed (cdt:fill-pts ls-ov-bl ls-a2-pl donut-size donut-layer ls-placed))
                 (setq ls-placed (cdt:fill-pts ls-ov-br ls-a2-pr donut-size donut-layer ls-placed))))
             (setq ls-placed (cdt:fill-pts ls-a2-pl ls-a2-pr donut-size donut-layer ls-placed))
             (setvar "CECOLOR" "256")

             ;; 2 אוגנים — בצד הנגדי מקווי המידות (נגד notch-right)
             (setq ls-sx0  (if notch-right
                             (- ls-x0 15.0 (cdt:bbox-width  ls-int1))
                             (+ ls-x1 15.0))
                   ls-sy1  (cadr ls-int1)
                   ls-sbb1 (list ls-sx0
                                 ls-sy1
                                 (+ ls-sx0  (cdt:bbox-width  ls-int1))
                                 (+ ls-sy1  (cdt:bbox-height ls-int1))))
             (cdt:log "[L26] ls-stirrup-1")
             (cdt:draw-stirrup-rect ls-sbb1 (cdt:get cfg "stirrup-layer")
               (cdt:get cfg "stirrup-style")
               (atof (cdt:get cfg "stirrup-height"))
               (cdt:get cfg "stirrup-color")
               (cdt:get cfg "stirrup-txt-color"))
             (cdt:log "[L27] after ls-stirrup-1")

             ;; BARS — תווית אוגן 1
             (if *cdt-bars-ok*
               (cdt:label-stirrup-safe ls-sbb1 (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-txt-color")))

             (setq ls-sx0-2 (if notch-right
                             (- (car ls-sbb1) 15.0 (cdt:bbox-width  ls-int2))
                             (+ (caddr ls-sbb1) 15.0))
                   ls-sy2   (cadr ls-int2)
                   ls-sbb2  (list ls-sx0-2
                                  ls-sy2
                                  (+ ls-sx0-2 (cdt:bbox-width  ls-int2))
                                  (+ ls-sy2   (cdt:bbox-height ls-int2))))
             (cdt:log "[L28] ls-stirrup-2")
             (cdt:draw-stirrup-rect ls-sbb2 (cdt:get cfg "stirrup-layer")
               (cdt:get cfg "stirrup-style")
               (atof (cdt:get cfg "stirrup-height"))
               (cdt:get cfg "stirrup-color")
               (cdt:get cfg "stirrup-txt-color"))
             (cdt:log "[L29] after ls-stirrup-2")

             ;; BARS — תווית אוגן 2
             (if *cdt-bars-ok*
               (cdt:label-stirrup-safe ls-sbb2 (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-txt-color")))

             ;; placed ו-conn-pt לבלוק מוטות — תחתית-ממורכז, מתחת לקו מידת הרוחב
             ;; זוג הדונאטים התחתונים (שמאל+ימין) → לידרים יורדים סימטרית למרכז
             (setq placed        ls-placed
                   bar-conn-pt   (list (* 0.5 (+ (car ls-overall) (caddr ls-overall)))
                                       (- (cadr ls-overall) CDT:DIM-OFFSET CDT:BAR-DIM-GAP))
                   bar-d1        (car (cdt:closest-and-farthest-donut ls-placed
                                        (list (car  ls-overall) (cadr ls-overall))))
                   bar-d2        (car (cdt:closest-and-farthest-donut ls-placed
                                        (list (caddr ls-overall) (cadr ls-overall)))))

             ;; top-y ו-cx לכותרת
             (setq top-y (cadddr ls-overall)
                   cx    (* 0.5 (+ (car ls-overall) (caddr ls-overall))))))

         ;; ─── בלוק מוטות ──────────────────────────────────────────
         (cdt:log "[L30] before bar-popup")
         (if placed
           (progn
             (setq cfg (cdt:bar-popup-dialog cfg))
             (cdt:log "[L31] after bar-popup")
             (if (and *cdt-bar-ok*
                      (not (equal (cdt:get cfg "bar-length") "0")))
               (progn
               (cdt:log "[L32] before draw-bar-block")
               (cdt:draw-bar-block
                 bar-d1 bar-d2 bar-conn-pt
                 (length placed)
                 (cdt:bar-opher   (cdt:get cfg "bar-type"))
                 (cdt:get cfg "bar-diameter")
                 (cdt:get cfg "bar-length")
                 (* 0.5 donut-size)
                 (cdt:get cfg "leader-layer")
                 (cdt:get cfg "leader-color")
                 (cdt:get cfg "donut-txt-style")
                 (atof (cdt:get cfg "donut-txt-height"))
                 (cdt:get cfg "donut-txt-color"))
               (cdt:log "[L33] after draw-bar-block")))))

         ;; ─── כותרת ────────────────────────────────────────────
         ;; שאלה על XData
         (if col-num
           (progn
             (initget "Yes No")
             (setq use-xdata
               (getkword
                 (strcat "\nFound column number: " col-num
                         " -- use it? [Yes/No] <Yes>: ")))
             (if (= use-xdata "No")
               (setq col-num (getstring t "\nEnter title content: "))))
           (setq col-num (getstring t "\nEnter column number: ")))

         ;; Scale
         (setq scale-str (getstring "\nScale 1:"))
         (if (= scale-str "") (setq scale-str "?"))

         ;; יצירת כותרת
         (cdt:log "[L40] create-title")
         (cdt:create-title col-num scale-str cfg top-y cx)
         (cdt:log "[L41] after create-title")

         ;; ─── יצירת בלוק והנחה בסרטוט ─────────────────────────
         (cdt:log "[L50] block-creation")
         (setq blk-ss (ssadd))
         (setq blk-e (if ent-before (entnext ent-before) (entnext)))
         (while blk-e
           (ssadd blk-e blk-ss)
           (setq blk-e (entnext blk-e)))

         (if (> (sslength blk-ss) 0)
           (progn
             ;; שם בלוק: CDT_ + מספר עמוד או חותמת זמן
             (setq blk-name
               (strcat "CDT_"
                 (if (and col-num (not (equal col-num "")))
                   col-num
                   (rtos (getvar "DATE") 2 0))))

             ;; נקודת בסיס = פינה שמאל-תחתית
             (setq blk-base
               (cond
                 (bb-ext      (list (car bb-ext)      (cadr bb-ext)))
                 (ls-overall  (list (car ls-overall)  (cadr ls-overall)))
                 (t           '(0.0 0.0))))

             ;; יצירת הגדרת בלוק — מסיר אובייקטים ומגדיר בלוק
             (if (tblsearch "BLOCK" blk-name)
               (command "_.BLOCK" blk-name "Yes" blk-base blk-ss "")
               (command "_.BLOCK" blk-name blk-base blk-ss ""))

             ;; הנחת הבלוק — PAUSE: הבלוק עוקב אחרי הסמן עד לחיצה
             (princ "\nPlace block (pick insertion point): ")
             (command "_.INSERT" blk-name PAUSE 1 1 0)))

         ;; שחזור OSNAP
         (setvar "OSMODE" prev-osmode)

         (princ "\nCOLDET complete.")))))

  (princ))

;;; ─── הודעת טעינה ─────────────────────────────────────────────
(princ "\nCOLDET 1.1 loaded. Run: COLDET\n")
(princ)
