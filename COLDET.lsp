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
(setq CDT:MAX-SPACING 19.0)   ; רווח מקסימלי בין דונאטים
(setq CDT:LEAD-DIST   10.0)   ; מרחק נקודת חיבור ליידר
(setq CDT:HOOK-LEN    10.0)   ; אורך וו אוגן
(setq CDT:HOOK-EXT     3.0)   ; הרחבה ויזואלית של וו (הפרדה)
(setq CDT:DIM-OFFSET  10.0)   ; מרחק קו מידה מהגיאומטריה החיצונית
(setq CDT:BAR-DIM-GAP 15.0)   ; מרווח אנכי של בלוק המוטות מתחת לקו מידת הרוחב
(setq CDT:TOL          1.0)   ; טולרנס (ס"מ) לכל ההשוואות הגיאומטריות במנוע הצורות

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

(defun cdt:bbox-intersect (a b)
  ; חיתוך שני מלבנים — מחזיר את מלבן החפיפה (minX minY maxX maxY)
  (list (max (car a)   (car b))
        (max (cadr a)  (cadr b))
        (min (caddr a) (caddr b))
        (min (cadddr a)(cadddr b))))

(defun cdt:ents-bbox-max (after / e obj ll ur lst maxx maxy)
  ; מחזיר (maxX maxY) של כל הישויות שנוצרו אחרי הישות 'after' (כולל טקסט מידות).
  ; משמש למקם כותרת/חישוקים ביחס לגבול האמיתי של מה שכבר צויר.
  (setq e (if after (entnext after) (entnext)))
  (while e
    (setq obj (vlax-ename->vla-object e))
    (vl-catch-all-apply
      '(lambda ()
         (vla-getboundingbox obj 'll 'ur)
         (setq lst (vlax-safearray->list ur))
         (if (or (null maxx) (> (car  lst) maxx)) (setq maxx (car  lst)))
         (if (or (null maxy) (> (cadr lst) maxy)) (setq maxy (cadr lst)))))
    (setq e (entnext e)))
  (list maxx maxy))

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

(defun cdt:draw-circle (center radius layer / prev e)
  ; מצייר מעגל בשכבה נתונה ומחזיר את הישות
  (cdt:ensure-layer layer)
  (setq prev (getvar "CLAYER"))
  (setvar "CLAYER" layer)
  (command "_.CIRCLE" center radius)
  (setq e (entlast))
  (setvar "CLAYER" prev)
  e)

(defun cdt:ensure-linetype (lt)
  ; טוען סוג קו (למשל CENTER) אם אינו קיים בסרטוט
  (if (not (tblsearch "LTYPE" lt))
    (vl-catch-all-apply 'command (list "_.-LINETYPE" "_Load" lt "acad.lin" ""))))

(defun cdt:set-center-lt (e / ed)
  ; קובע סוג-קו CENTER ו-LTScale=1 ישירות על הישות (בלי לגעת ב-CELTYPE הגלובלי)
  (if (and e (tblsearch "LTYPE" "CENTER"))
    (progn
      (setq ed (entget e))
      (setq ed (vl-remove-if '(lambda (x) (or (= (car x) 6) (= (car x) 48))) ed))
      (setq ed (append ed (list (cons 6 "CENTER") (cons 48 1.0))))
      (entmod ed)
      (entupd e))))

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
  ; inset רגיל = 0.8*size (מיושר עם קוסטום — היה 1.2, קורב לחישוק הפנימי), אבל לא יותר ממחצית הצלע
  ; הקטנה ביותר של bb — כדי שדונאט בעמוד קטן לא "יעבור" את המרכז לצד השני
  (setq raw      (* 0.8 size)
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
;;; F2. מנוע צורות — פינות קעורות ומפענחי צורה
;;; ============================================================

(defun cdt:reflex-vertices (verts / vs n area i p0 p1 p2 e1x e1y e2x e2y cr ccw res)
  ; פינות קעורות אמיתיות — לפי כיוון הפנייה של המתאר בכל פינה (מבחן קעור/קמור),
  ; ולא לפי "בתוך התיבה" (שנשבר ברגליים לא-שוות).
  (setq vs verts)
  ; הסרת קודקוד-סגירה כפול (אם הנקודה האחרונה = הראשונה)
  (if (and (> (length vs) 1)
           (< (distance (list (car (car vs))  (cadr (car vs)))
                        (list (car (last vs)) (cadr (last vs)))) CDT:TOL))
    (setq vs (reverse (cdr (reverse vs)))))
  (setq n (length vs))
  (if (< n 3)
    nil
    (progn
      ; שטח חתום — לקביעת כיוון הסיבוב (CCW אם חיובי)
      (setq area 0.0  i 0)
      (while (< i n)
        (setq p1   (nth i vs)
              p2   (nth (rem (1+ i) n) vs)
              area (+ area (- (* (car p1) (cadr p2)) (* (car p2) (cadr p1))))
              i    (1+ i)))
      (setq ccw (> area 0.0)  res nil  i 0)
      (while (< i n)
        (setq p0  (nth (rem (+ i (1- n)) n) vs)   ; קודקוד קודם
              p1  (nth i vs)
              p2  (nth (rem (1+ i) n) vs)         ; קודקוד הבא
              e1x (- (car p1) (car p0))  e1y (- (cadr p1) (cadr p0))
              e2x (- (car p2) (car p1))  e2y (- (cadr p2) (cadr p1))
              cr  (- (* e1x e2y) (* e1y e2x)))
        ; קעור אם כיוון הפנייה הפוך לכיוון הכללי של המתאר
        (if (if ccw (< cr 0.0) (> cr 0.0))
          (setq res (append res (list p1))))
        (setq i (1+ i)))
      res)))

(defun cdt:perp-coord (verts val isX ref tol / best bd pc d)
  ; על הקו שבו אחד הצירים = val, מחזיר את הקואורדינטה הניצבת של הקודקוד
  ; הרחוק ביותר מ-ref (כלומר קצה הרגל, ולא הפינה הקעורה עצמה שיושבת על ref)
  (setq best nil  bd -1.0)
  (foreach v verts
    (if (< (abs (- (if isX (car v) (cadr v)) val)) tol)
      (progn
        (setq pc (if isX (cadr v) (car v))  d (abs (- pc ref)))
        (if (> d bd) (setq bd d  best pc)))))
  best)

(defun cdt:chet-decompose (verts offset / bb tol reflex r1 r2
                            x0 y0 x1 y1 cn lo hi tipa tipb beamfar
                            beam legA legB)
  ; מפענח צורת ח: מחזיר (overall-bbox (beam legA legB)) או nil אם לא תקין.
  ; מטפל ב-4 הכיוונים וברגליים לא-שוות. המלבנים הם החיצוניים (לא מוקטנים).
  (setq bb     (cdt:bbox-from-verts verts)
        tol    CDT:TOL
        reflex (cdt:reflex-vertices verts)
        x0 (car bb)  y0 (cadr bb)  x1 (caddr bb)  y1 (cadddr bb))
  (if (/= (length reflex) 2)
    nil                                    ; חייב בדיוק 2 פינות קעורות
    (progn
      (setq r1 (car reflex)  r2 (cadr reflex)  beam nil)
      (cond
        ;; תקרה אופקית — הפינות חולקות Y → פתח למעלה/למטה, רגליים אנכיות
        ((< (abs (- (cadr r1) (cadr r2))) tol)
         (setq cn   (cadr r1)
               lo   (min (car r1) (car r2))
               hi   (max (car r1) (car r2))
               tipa (cdt:perp-coord verts lo T cn tol)
               tipb (cdt:perp-coord verts hi T cn tol))
         (if (and tipa tipb)
           (setq beamfar (if (< tipa cn) y1 y0)
                 beam (list x0 (min cn beamfar) x1 (max cn beamfar))
                 legA (list x0 (min beamfar tipa) lo (max beamfar tipa))
                 legB (list hi (min beamfar tipb) x1 (max beamfar tipb)))))
        ;; תקרה אנכית — הפינות חולקות X → פתח שמאלה/ימינה, רגליים אופקיות
        ((< (abs (- (car r1) (car r2))) tol)
         (setq cn   (car r1)
               lo   (min (cadr r1) (cadr r2))
               hi   (max (cadr r1) (cadr r2))
               tipa (cdt:perp-coord verts lo nil cn tol)
               tipb (cdt:perp-coord verts hi nil cn tol))
         (if (and tipa tipb)
           (setq beamfar (if (< tipa cn) x1 x0)
                 beam (list (min cn beamfar) y0 (max cn beamfar) y1)
                 legA (list (min beamfar tipa) y0 (max beamfar tipa) lo)
                 legB (list (min beamfar tipb) hi (max beamfar tipb) y1)))))
      (if beam (list bb (list beam legA legB)) nil))))

(defun cdt:chet-leg-donuts (leg ov beam-cen size layer placed /
                            tol lx0 ly0 lx1 ly1 ox0 oy0 ox1 oy1
                            l-inset l-cen ov-inset ov-cen vert
                            freeY ceilY farY innerX outerX
                            freeX ceilX farX innerY outerY
                            p-fo p-fi p-oc p-reflex p-ofar p-iffar)
  ; דונאטים של רגל אחת: 2 פינות קצה חופשי + מילוי 3 הצלעות החיצוניות שלה.
  ; מחזיר (placed p-ofar p-reflex p-iffar) — עוגנים לחיבור הקורה אחר כך.
  (setq tol     CDT:TOL
        lx0 (car leg) ly0 (cadr leg) lx1 (caddr leg) ly1 (cadddr leg)
        ox0 (car ov)  oy0 (cadr ov)  ox1 (caddr ov)  oy1 (cadddr ov)
        l-inset  (cdt:donut-inset size leg)  l-cen  (cdt:bbox-center leg)
        ov-inset (cdt:donut-inset size ov)   ov-cen (cdt:bbox-center ov)
        vert (or (> (- oy0 ly0) tol) (> (- ly1 oy1) tol)))
  (if vert
    (progn
      (if (> (- oy0 ly0) tol)
        (setq freeY ly0 ceilY oy0 farY ly1)     ; רגל יורדת מטה
        (setq freeY ly1 ceilY oy1 farY ly0))    ; רגל עולה מעלה
      (if (> (car beam-cen) (car l-cen))
        (setq innerX lx1 outerX lx0)            ; פנים (לכיוון התקרה) מימין
        (setq innerX lx0 outerX lx1))
      (setq p-fo     (cdt:corner-toward-center (list outerX freeY) l-cen  l-inset)
            p-fi     (cdt:corner-toward-center (list innerX freeY) l-cen  l-inset)
            p-oc     (cdt:corner-toward-center (list outerX ceilY) ov-cen ov-inset)
            p-reflex (cdt:corner-toward-center (list innerX ceilY) ov-cen ov-inset)
            p-ofar   (cdt:corner-toward-center (list outerX farY)  ov-cen ov-inset)
            p-iffar  (cdt:corner-toward-center (list innerX farY)  ov-cen ov-inset)))
    (progn
      (if (> (- ox0 lx0) tol)
        (setq freeX lx0 ceilX ox0 farX lx1)     ; רגל יוצאת שמאלה
        (setq freeX lx1 ceilX ox1 farX lx0))    ; רגל יוצאת ימינה
      (if (> (cadr beam-cen) (cadr l-cen))
        (setq innerY ly1 outerY ly0)            ; פנים (לכיוון התקרה) למעלה
        (setq innerY ly0 outerY ly1))
      (setq p-fo     (cdt:corner-toward-center (list freeX outerY) l-cen  l-inset)
            p-fi     (cdt:corner-toward-center (list freeX innerY) l-cen  l-inset)
            p-oc     (cdt:corner-toward-center (list ceilX outerY) ov-cen ov-inset)
            p-reflex (cdt:corner-toward-center (list ceilX innerY) ov-cen ov-inset)
            p-ofar   (cdt:corner-toward-center (list farX  outerY) ov-cen ov-inset)
            p-iffar  (cdt:corner-toward-center (list farX  innerY) ov-cen ov-inset))))
  ;; פינות הקצה החופשי
  (setq placed (cdt:donut-if-new p-fo size layer placed)
        placed (cdt:donut-if-new p-fi size layer placed))
  ;; צלע חיצונית מלאה: קצה חופשי -> גובה התקרה -> הקצה הרחוק (צד הקורה)
  (setq placed (cdt:fill-pts p-fo p-oc   size layer placed)
        placed (cdt:fill-pts p-oc p-ofar size layer placed))
  ;; צלע פנימית — רק עד התקרה (מעבר לזה זה פנים החומר)
  (setq placed (cdt:fill-pts p-fi p-reflex size layer placed))
  ;; צלע הקצה החופשי
  (setq placed (cdt:fill-pts p-fo p-fi size layer placed))
  (list placed p-ofar p-reflex p-iffar))

(defun cdt:chet-dimensions (rects bb dim-off / beam legA legB horiz
                            legL legR openLow ceilC topC hpos fL fR xL xR
                            legBot legTop openLeft nearC farEdge nearpos fB fT yB yT)
  ; קווי מידה לצורת ח על 3 צדדים בלבד (הגב הסגור לא מקבל מידה):
  ; הצד הפתוח — רוחב 2 הרגליים + המגרעת; וכל רגל בצידה — אורך מהקצה עד
  ; הגוף + מידת השלמה. תומך בכל 4 סיבובי הצורה (פתח למעלה/למטה/שמאל/ימין).
  (setq beam  (nth 0 rects)  legA (nth 1 rects)  legB (nth 2 rects)
        horiz (> (cdt:bbox-width beam) (cdt:bbox-height beam)))
  (if horiz
    (progn
      ;; רגליים אנכיות — פתח למעלה/למטה
      (if (< (car legA) (car legB)) (setq legL legA legR legB) (setq legL legB legR legA))
      (setq openLow (< (cadr legL) (cadr beam)))
      (if openLow
        (setq ceilC (cadr beam)   topC (cadddr beam) hpos (- (cadr bb)   dim-off))
        (setq ceilC (cadddr beam) topC (cadr beam)   hpos (+ (cadddr bb) dim-off)))
      (setq fL (if openLow (cadr legL) (cadddr legL))
            fR (if openLow (cadr legR) (cadddr legR))
            xL (- (car bb)   dim-off)
            xR (+ (caddr bb) dim-off))
      ;; צד פתוח — רוחב רגל-שמאל, מגרעת, רוחב רגל-ימין
      (command "_.DIMLINEAR" (list (car legL) fL) (list (caddr legL) fL)
        (list (* 0.5 (+ (car legL) (caddr legL))) hpos))
      (command "_.DIMLINEAR" (list (caddr legL) fL) (list (car legR) fL)
        (list (* 0.5 (+ (caddr legL) (car legR))) hpos))
      (command "_.DIMLINEAR" (list (car legR) fR) (list (caddr legR) fR)
        (list (* 0.5 (+ (car legR) (caddr legR))) hpos))
      ;; רגל שמאל — אורך + השלמה
      (command "_.DIMLINEAR" (list (car legL) fL) (list (car legL) ceilC)
        (list xL (* 0.5 (+ fL ceilC))))
      (command "_.DIMLINEAR" (list (car legL) ceilC) (list (car legL) topC)
        (list xL (* 0.5 (+ ceilC topC))))
      ;; רגל ימין — אורך + השלמה
      (command "_.DIMLINEAR" (list (caddr legR) fR) (list (caddr legR) ceilC)
        (list xR (* 0.5 (+ fR ceilC))))
      (command "_.DIMLINEAR" (list (caddr legR) ceilC) (list (caddr legR) topC)
        (list xR (* 0.5 (+ ceilC topC)))))
    (progn
      ;; רגליים אופקיות — פתח שמאלה/ימינה
      (if (< (cadr legA) (cadr legB)) (setq legBot legA legTop legB) (setq legBot legB legTop legA))
      (setq openLeft (< (car legBot) (car beam)))
      (if openLeft
        (setq nearC (car beam)   farEdge (caddr beam) nearpos (- (car bb)   dim-off))
        (setq nearC (caddr beam) farEdge (car beam)   nearpos (+ (caddr bb) dim-off)))
      (setq fB (if openLeft (car legBot) (caddr legBot))
            fT (if openLeft (car legTop) (caddr legTop))
            yB (- (cadr bb)   dim-off)
            yT (+ (cadddr bb) dim-off))
      ;; צד פתוח — גובה רגל-תחתונה, מגרעת, גובה רגל-עליונה
      (command "_.DIMLINEAR" (list fB (cadr legBot)) (list fB (cadddr legBot))
        (list nearpos (* 0.5 (+ (cadr legBot) (cadddr legBot)))))
      (command "_.DIMLINEAR" (list fB (cadddr legBot)) (list fB (cadr legTop))
        (list nearpos (* 0.5 (+ (cadddr legBot) (cadr legTop)))))
      (command "_.DIMLINEAR" (list fT (cadr legTop)) (list fT (cadddr legTop))
        (list nearpos (* 0.5 (+ (cadr legTop) (cadddr legTop)))))
      ;; רגל תחתונה — אורך + השלמה
      (command "_.DIMLINEAR" (list fB (cadr legBot)) (list nearC (cadr legBot))
        (list (* 0.5 (+ fB nearC)) yB))
      (command "_.DIMLINEAR" (list nearC (cadr legBot)) (list farEdge (cadr legBot))
        (list (* 0.5 (+ nearC farEdge)) yB))
      ;; רגל עליונה — אורך + השלמה
      (command "_.DIMLINEAR" (list fT (cadddr legTop)) (list nearC (cadddr legTop))
        (list (* 0.5 (+ fT nearC)) yT))
      (command "_.DIMLINEAR" (list nearC (cadddr legTop)) (list farEdge (cadddr legTop))
        (list (* 0.5 (+ nearC farEdge)) yT))))
  (princ))

(defun cdt:zshape-decompose (verts / bb tol reflex r1 r2 x0 y0 x1 y1
                              dx dy wx0 wx1 wy0 wy1
                              r-up r-low r-right r-left body fa fb)
  ; מפענח צורת זי (Z/S): מחזיר (overall-bbox (body flangeA flangeB)) או nil.
  ; מבנה זהה ל-ח' — 3 מלבנים חופפים (גוף מרכזי + 2 כנפיים, 2 אזורי חפיפה),
  ; אבל שתי הפינות הקעורות באלכסון (לא חולקות קו) והכנפיים יוצאות לכיוונים מנוגדים.
  ; תומך בכל הסיבובים: גוף אנכי (כנפיים אופקיות) או גוף אופקי (כנפיים אנכיות).
  (setq bb     (cdt:bbox-from-verts verts)
        tol    CDT:TOL
        reflex (cdt:reflex-vertices verts)
        x0 (car bb) y0 (cadr bb) x1 (caddr bb) y1 (cadddr bb))
  (if (/= (length reflex) 2)
    nil                                    ; חייב בדיוק 2 פינות קעורות
    (progn
      (setq r1 (car reflex) r2 (cadr reflex)
            dx (abs (- (car r1)  (car r2)))
            dy (abs (- (cadr r1) (cadr r2))))
      (cond
        ;; הפינות חולקות קו → זו ח' ולא זי
        ((or (< dx tol) (< dy tol)) (setq body nil))
        ;; ── גוף אנכי (כנפיים אופקיות): הפרש ה-X קטן מהפרש ה-Y ──
        ((< dx dy)
         (setq wx0   (min (car r1) (car r2))
               wx1   (max (car r1) (car r2))
               body  (list wx0 y0 wx1 y1)                 ; גוף לכל הגובה
               r-up  (if (> (cadr r1) (cadr r2)) r1 r2)   ; פינה קעורה גבוהה
               r-low (if (> (cadr r1) (cadr r2)) r2 r1))  ; פינה קעורה נמוכה
         ;; כנף עליונה: רצועת y מ-r-up עד y1, משתרעת לצד שבו יושבת r-up
         (setq fa (if (> (- (car r-up) wx0) tol)
                    (list wx0 (cadr r-up) x1  y1)          ; r-up על הקצה הימני → ימינה
                    (list x0  (cadr r-up) wx1 y1)))        ; r-up על הקצה השמאלי → שמאלה
         ;; כנף תחתונה: רצועת y מ-y0 עד r-low, הצד ההפוך (אלכסון)
         (setq fb (if (> (- (car r-low) wx0) tol)
                    (list wx0 y0 x1  (cadr r-low))         ; ימינה
                    (list x0  y0 wx1 (cadr r-low)))))      ; שמאלה
        ;; ── גוף אופקי (כנפיים אנכיות): הפרש ה-Y קטן ──
        (t
         (setq wy0     (min (cadr r1) (cadr r2))
               wy1     (max (cadr r1) (cadr r2))
               body    (list x0 wy0 x1 wy1)                ; גוף לכל הרוחב
               r-right (if (> (car r1) (car r2)) r1 r2)    ; פינה קעורה ימנית
               r-left  (if (> (car r1) (car r2)) r2 r1))   ; פינה קעורה שמאלית
         ;; כנף ימנית: רצועת x מ-r-right עד x1, מעלה/מטה לפי r-right
         (setq fa (if (> (- (cadr r-right) wy0) tol)
                    (list (car r-right) wy0 x1 y1)         ; r-right למעלה → כנף מעלה
                    (list (car r-right) y0  x1 wy1)))      ; r-right למטה → כנף מטה
         ;; כנף שמאלית: הצד ההפוך
         (setq fb (if (> (- (cadr r-left) wy0) tol)
                    (list x0 wy0 (car r-left) y1)          ; מעלה
                    (list x0 y0  (car r-left) wy1)))))      ; מטה
      (if body (list bb (list body fa fb)) nil))))

(defun cdt:z-brk (lo hi e0 e1)
  ; מחזיר את קצה הגוף (e0 או e1) שנמצא ממש בתוך הקטע (lo..hi) — נקודת שבירת השרשרת
  (if (and (> e1 lo) (< e1 hi)) e1 e0))

(defun cdt:zshape-dimensions (rects bb dim-off / body fa fb x0 y0 x1 y1 vert
                              wx0 wx1 wy0 wy1 fUp fLo fRt fLf ylo yup
                              faL faR fbL fbR ba bk xlf xrt faB faT fbB fbT)
  ; 3 קווי מידה לזי (כמו ח'): שרשרת לגוף בצד נבחר (עובי כנף → מרווח → עובי כנף)
  ; + קו לכל כנף (אורך הכנף + השלמה לרוחב הגוף). תומך בגוף אנכי ובגוף אופקי.
  (setq body (nth 0 rects) fa (nth 1 rects) fb (nth 2 rects)
        x0 (car bb) y0 (cadr bb) x1 (caddr bb) y1 (cadddr bb)
        vert (> (cdt:bbox-height body) (cdt:bbox-width body)))
  (if vert
    ;; ── גוף אנכי: כנפיים אופקיות ──
    (progn
      (setq wx0 (car body) wx1 (caddr body)
            fUp (if (> (cadr (cdt:bbox-center fa)) (cadr (cdt:bbox-center fb))) fa fb)
            fLo (if (equal fUp fa) fb fa)
            yup (cadr   fUp)        ; תחתית הכנף העליונה
            ylo (cadddr fLo))       ; ראש הכנף התחתונה
      ;; (1) שרשרת הגוף — נמדדת מצלע הגוף (wx0), קו המידה 20 יח' החוצה ממנה
      (command "_.DIMLINEAR" (list wx0 y0)  (list wx0 ylo)
        (list (- wx0 20.0) (* 0.5 (+ y0 ylo))))
      (command "_.DIMLINEAR" (list wx0 ylo) (list wx0 yup)
        (list (- wx0 20.0) (* 0.5 (+ ylo yup))))
      (command "_.DIMLINEAR" (list wx0 yup) (list wx0 y1)
        (list (- wx0 20.0) (* 0.5 (+ yup y1))))
      ;; (2) כנף עליונה — למעלה: רוחב הגוף + אורך הכנף
      (setq faL (car fUp) faR (caddr fUp) ba (cdt:z-brk faL faR wx0 wx1))
      (command "_.DIMLINEAR" (list faL y1) (list ba y1)
        (list (* 0.5 (+ faL ba)) (+ y1 dim-off)))
      (command "_.DIMLINEAR" (list ba y1) (list faR y1)
        (list (* 0.5 (+ ba faR)) (+ y1 dim-off)))
      ;; (3) כנף תחתונה — למטה: אורך הכנף + רוחב הגוף
      (setq fbL (car fLo) fbR (caddr fLo) bk (cdt:z-brk fbL fbR wx0 wx1))
      (command "_.DIMLINEAR" (list fbL y0) (list bk y0)
        (list (* 0.5 (+ fbL bk)) (- y0 dim-off)))
      (command "_.DIMLINEAR" (list bk y0) (list fbR y0)
        (list (* 0.5 (+ bk fbR)) (- y0 dim-off))))
    ;; ── גוף אופקי: כנפיים אנכיות ──
    (progn
      (setq wy0 (cadr body) wy1 (cadddr body)
            fRt (if (> (car (cdt:bbox-center fa)) (car (cdt:bbox-center fb))) fa fb)
            fLf (if (equal fRt fa) fb fa)
            xrt (car   fRt)         ; שמאל הכנף הימנית
            xlf (caddr fLf))        ; ימין הכנף השמאלית
      ;; (1) שרשרת הגוף — נמדדת מצלע הגוף (wy0), קו המידה 20 יח' החוצה ממנה
      (command "_.DIMLINEAR" (list x0 wy0)  (list xlf wy0)
        (list (* 0.5 (+ x0 xlf)) (- wy0 20.0)))
      (command "_.DIMLINEAR" (list xlf wy0) (list xrt wy0)
        (list (* 0.5 (+ xlf xrt)) (- wy0 20.0)))
      (command "_.DIMLINEAR" (list xrt wy0) (list x1 wy0)
        (list (* 0.5 (+ xrt x1)) (- wy0 20.0)))
      ;; (2) כנף ימנית — מימין: השלמה לגובה הגוף + אורך הכנף
      (setq faB (cadr fRt) faT (cadddr fRt) ba (cdt:z-brk faB faT wy0 wy1))
      (command "_.DIMLINEAR" (list x1 faB) (list x1 ba)
        (list (+ x1 dim-off) (* 0.5 (+ faB ba))))
      (command "_.DIMLINEAR" (list x1 ba) (list x1 faT)
        (list (+ x1 dim-off) (* 0.5 (+ ba faT))))
      ;; (3) כנף שמאלית — משמאל
      (setq fbB (cadr fLf) fbT (cadddr fLf) bk (cdt:z-brk fbB fbT wy0 wy1))
      (command "_.DIMLINEAR" (list x0 fbB) (list x0 bk)
        (list (- x0 dim-off) (* 0.5 (+ fbB bk))))
      (command "_.DIMLINEAR" (list x0 bk) (list x0 fbT)
        (list (- x0 dim-off) (* 0.5 (+ bk fbT))))))
  (princ))

(defun cdt:vert-near-p (verts pt tol / found)
  ; האם קיים בפוליגון קודקוד ממש ב-pt (בטולרנס) — משמש לאמת "מדרגה" אמיתית
  ; (חתימת ט', בניגוד ל-ח' שם הצלע רציפה בלי קודקוד שם)
  (setq found nil)
  (foreach v verts
    (if (and (< (abs (- (car v)  (car pt)))  tol)
             (< (abs (- (cadr v) (cadr pt))) tol))
      (setq found T)))
  found)

(defun cdt:tshape-decompose (verts / bb tol reflex r1 r2 x0 y0 x1 y1
                              cn lo hi tip tip2 flange stem ffar)
  ; מפענח צורת ט: מחזיר (overall-bbox (flange stem)) או nil אם לא תקין.
  ; ט = כנף (רוחב מלא) + רגל אחת ממורכזת (לא מגיעה לקצוות הכנף) — בשונה מ-ח'
  ; שם הרגליים כן מגיעות לקצוות. האימות: קיים קודקוד ב-(x0,cn)/(x1,cn) (המדרגה
  ; של הכנף) — ב-ח' אין קודקוד כזה (הצלע שם רציפה מקצה לקצה).
  (setq bb     (cdt:bbox-from-verts verts)
        tol    CDT:TOL
        reflex (cdt:reflex-vertices verts)
        x0 (car bb)  y0 (cadr bb)  x1 (caddr bb)  y1 (cadddr bb))
  (if (/= (length reflex) 2)
    nil                                    ; חייב בדיוק 2 פינות קעורות
    (progn
      (setq r1 (car reflex)  r2 (cadr reflex)  flange nil)
      (cond
        ;; תקרה אופקית — הפינות חולקות Y → הרגל אנכית (כנף מלאה ברוחב)
        ((< (abs (- (cadr r1) (cadr r2))) tol)
         (setq cn   (cadr r1)
               lo   (min (car r1) (car r2))
               hi   (max (car r1) (car r2))
               tip  (cdt:perp-coord verts lo T cn tol)
               tip2 (cdt:perp-coord verts hi T cn tol))
         (if (and tip tip2 (< (abs (- tip tip2)) tol)
                  (cdt:vert-near-p verts (list x0 cn) tol)
                  (cdt:vert-near-p verts (list x1 cn) tol))
           (progn
             (setq ffar (if (< tip cn) y1 y0))
             (setq flange (list x0 (min cn ffar) x1 (max cn ffar))
                   stem   (list lo (min cn tip) hi (max cn tip))))))
        ;; תקרה אנכית — הפינות חולקות X → הרגל אופקית (כנף מלאה בגובה)
        ((< (abs (- (car r1) (car r2))) tol)
         (setq cn   (car r1)
               lo   (min (cadr r1) (cadr r2))
               hi   (max (cadr r1) (cadr r2))
               tip  (cdt:perp-coord verts lo nil cn tol)
               tip2 (cdt:perp-coord verts hi nil cn tol))
         (if (and tip tip2 (< (abs (- tip tip2)) tol)
                  (cdt:vert-near-p verts (list cn y0) tol)
                  (cdt:vert-near-p verts (list cn y1) tol))
           (progn
             (setq ffar (if (< tip cn) x1 x0))
             (setq flange (list (min cn ffar) y0 (max cn ffar) y1)
                   stem   (list (min cn tip) lo (max cn tip) hi))))))
      (if flange (list bb (list flange stem)) nil))))

(defun cdt:tshape-dimensions (rects bb dim-off / flange stem horiz
                              openLow ceilC topC hpos fY xS
                              openLeft nearpos fX yS)
  ; קווי מידה לצורת ט: צד פתוח = 3 מקטעים (אוזן/רגל/אוזן), ועוד אורך הרגל
  ; + השלמה לגובה/רוחב הכולל. תומך בכנף אופקית (רגל אנכית) ובכנף אנכית (רגל אופקית).
  (setq flange (nth 0 rects)  stem (nth 1 rects)
        horiz  (> (cdt:bbox-width flange) (cdt:bbox-height flange)))
  (if horiz
    (progn
      ;; כנף אופקית (רוחב מלא), רגל אנכית — פתח למעלה/למטה
      (setq openLow (< (cadr stem) (cadr flange)))
      (if openLow
        (setq ceilC (cadr flange) topC (cadddr flange) hpos (- (cadr bb)   dim-off) fY (cadr    stem))
        (setq ceilC (cadddr flange) topC (cadr flange) hpos (+ (cadddr bb) dim-off) fY (cadddr stem)))
      ;; צד פתוח — אוזן שמאל / רגל / אוזן ימין
      (command "_.DIMLINEAR" (list (car bb) fY) (list (car stem) fY)
        (list (* 0.5 (+ (car bb) (car stem))) hpos))
      (command "_.DIMLINEAR" (list (car stem) fY) (list (caddr stem) fY)
        (list (* 0.5 (+ (car stem) (caddr stem))) hpos))
      (command "_.DIMLINEAR" (list (caddr stem) fY) (list (caddr bb) fY)
        (list (* 0.5 (+ (caddr stem) (caddr bb))) hpos))
      ;; הרגל — אורך + השלמה לגובה הכולל
      (setq xS (- (car stem) dim-off))
      (command "_.DIMLINEAR" (list (car stem) fY) (list (car stem) ceilC)
        (list xS (* 0.5 (+ fY ceilC))))
      (command "_.DIMLINEAR" (list (car stem) ceilC) (list (car stem) topC)
        (list xS (* 0.5 (+ ceilC topC)))))
    (progn
      ;; כנף אנכית (גובה מלא), רגל אופקית — פתח שמאלה/ימינה
      (setq openLeft (< (car stem) (car flange)))
      (if openLeft
        (setq ceilC (car flange) topC (caddr flange) nearpos (- (car bb)   dim-off) fX (car    stem))
        (setq ceilC (caddr flange) topC (car flange) nearpos (+ (caddr bb) dim-off) fX (caddr stem)))
      (command "_.DIMLINEAR" (list fX (cadr bb)) (list fX (cadr stem))
        (list nearpos (* 0.5 (+ (cadr bb) (cadr stem)))))
      (command "_.DIMLINEAR" (list fX (cadr stem)) (list fX (cadddr stem))
        (list nearpos (* 0.5 (+ (cadr stem) (cadddr stem)))))
      (command "_.DIMLINEAR" (list fX (cadddr stem)) (list fX (cadddr bb))
        (list nearpos (* 0.5 (+ (cadddr stem) (cadddr bb)))))
      ;; הרגל — אורך + השלמה לרוחב הכולל
      (setq yS (- (cadr stem) dim-off))
      (command "_.DIMLINEAR" (list fX (cadr stem)) (list ceilC (cadr stem))
        (list (* 0.5 (+ fX ceilC)) yS))
      (command "_.DIMLINEAR" (list ceilC (cadr stem)) (list topC (cadr stem))
        (list (* 0.5 (+ ceilC topC)) yS))))
  (princ))

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
  ; מספר אורך הצלע האנכית: בחישוק גבוה — מימין (מירור לבלוק שמשמאל); אחרת — משמאל
  (if (> (- y1 y0) (- x1 x0))
    (cdt:draw-text-center (list (+ x1 2.0 th) (* 0.5 (+ y0 y1))) th sty txt-h stirrup-layer 90 nil)
    (cdt:draw-text-center (list (- x0 2.0) (* 0.5 (+ y0 y1))) th sty txt-h stirrup-layer 90 nil))
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
        y2     (- (+ top-y h1 (* 0.5 h2)) 2.0)   ; הטקסט התחתון (קנ"מ) — 2 יחידות למטה, להתרחק מהקו המפריד
        yl     (+ top-y h1 h2 (* 2.0 gap))
        y1     (+ yl gap (* 0.5 h1)))

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
  ; מרווח קבוע ביחס לגובה המספר (לא גדל עם מספר הספרות — הרוחב כבר מטופל במרכוז)
  (setq gap-btw (* 2.5 hn)
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

  ; קו מפריד — מעוגן לקצוות הטקסט עצמו: משמאל קצה המספר, מימין קצה העברית,
  ; + 3 יח' מכל צד. כך הוא מיושר עם הטקסט גם כשהמרכוז אינו מדויק.
  ; רוחב עברי נדיב (0.75) לקצה הימני, כי textbox מזלזל בעברית.
  (if (equal txt1 "")
    (setq x0 (- cx-num (* 0.5 w-num) 3.0)
          x1 (+ cx-num (* 0.5 w-num) 3.0))
    (setq x0 (- cx-num (* 0.5 w-num) 3.0)
          x1 (+ cx-heb (* 0.5 (max w-heb (* (strlen txt1) h1 0.75))) 7.0)))
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

(defun cdt:dialog-write (cfg / ll sl dl)
  (setq ll (cdt:get-all-layers)
        sl (cdt:get-all-txtstyles)
        dl (cdt:get-all-dimstyles)
        *cdt-layer-list* ll
        *cdt-style-list* sl
        *cdt-dimstyle-list* dl)
  ; מילוי רשימות
  (cdt:fill-popup "ext_layer"     ll)  (cdt:fill-popup "int_layer"     ll)
  (cdt:fill-popup "donut_layer"   ll)  (cdt:fill-popup "dim_layer"     ll)
  (cdt:fill-popup "title_layer1"  ll)  (cdt:fill-popup "title_layer2"  ll)
  (cdt:fill-popup "stirrup_layer" ll)
  (cdt:fill-popup "leader_layer"  ll)
  (cdt:fill-popup "dim_style"        dl)
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
  (cdt:set-popup "dim_style"        dl (cdt:get cfg "dim-style"))
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
  (set_tile "dim_scale"          (cdt:str-or-empty (cdt:get cfg "dim-scale")))
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
  (setq cfg (cdt:set! cfg "dim-style"      (cdt:get-popup "dim_style"       *cdt-dimstyle-list*)))
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

(defun cdt:settings-dialog (cfg-in / dlg-id done ldir res ent ed old-dimstyle dsc)
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
                   ;; קנה מידה של המידה הנבחרת — מסגנון המידה שלה (group 40), אחרת DIMSCALE הנוכחי
                   (setq dsc (cond
                               ((and (assoc 3 ed)
                                     (tblsearch "DIMSTYLE" (cdr (assoc 3 ed)))
                                     (assoc 40 (tblsearch "DIMSTYLE" (cdr (assoc 3 ed)))))
                                (cdr (assoc 40 (tblsearch "DIMSTYLE" (cdr (assoc 3 ed))))))
                               (t (getvar "DIMSCALE"))))
                   (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "dim-scale"
                     (rtos dsc 2 4))))))

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

(defun cdt:stirrup-dialog-safe (bb)
  ; פותח את דיאלוג החישוקים פעם אחת; מחזיר vals (סוג/קוטר/פסיעה) או nil בביטול
  (if *cdt-bars-ok* (bars:stirrup-dialog bb)))

(defun cdt:draw-stirrup-label-safe (bb vals layer txt-style txt-height txt-color)
  ; מצייר תווית חישוק מ-vals שנאספו כבר (בלי דיאלוג); L= מחושב מחדש לפי bb
  (if (and *cdt-bars-ok* vals)
    (bars:draw-stirrup-label bb vals layer txt-style txt-height txt-color)))

(defun cdt:bar-opher (type-str)
  ; סוגים 1 ו-2 הוחלפו: בחירת 1 נותנת %%157, בחירת 2 נותנת %%156
  (cond ((= type-str "1") "%%157")
        ((= type-str "2") "%%156")
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

(defun cdt:bar-block-conn-pt (bb-ext cfg / txt-h)
  ; ברירת מחדל לבלוק מוטות: אלכסון ימין-מטה מהפינה הימנית-תחתונה של הגיאומטריה החיצונית.
  ; מרחק אחיד מהפינה לקצה הטקסט בשני הצירים = 1.5×גובה הטקסט.
  ; ההחזרה היא הקצה השמאלי של הקו; באנכי מתחשבים במבנה הבלוק (שוליים-קו 3 + מרווח 1 + גובה הטקסט),
  ; כך שהמרחק מהפינה לקצה העליון של הטקסט שווה למרחק האופקי.
  (setq txt-h (atof (cdt:get cfg "donut-txt-height"))
        txt-h (if (> txt-h 0.0) txt-h 2.5))
  (list (+ (caddr bb-ext) (* 1.5 txt-h))
        (- (cadr bb-ext) (* 1.5 txt-h) 3.0 1.0 txt-h)))

(defun cdt:draw-bar-block (d1 d2 conn-pt qty bar-char bar-diam bar-len donut-radius layer line-color txt-style txt-height txt-color /
                              txt lx ly text-x top-y txt-h gap line-y dx dy dist edge1 edge2 near-pt
                              tb txt-w line-len use-style)
  ; conn-pt = הקצה השמאלי של הקו (נקודת האלכסון מהפינה הימנית-תחתונה); הבלוק נמתח ימינה
  (setq txt (strcat (itoa qty) bar-char bar-diam
                    (if (and (stringp bar-len) (> (strlen bar-len) 0)
                             (not (equal bar-len "0")))
                      (strcat " L=" bar-len) ""))
        lx         (car  conn-pt)
        ly         (cadr conn-pt)
        txt-h      (if (and txt-height (> txt-height 0.0)) txt-height 2.5)
        gap        1.0
        line-y     ly)
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
  (setq line-len (+ txt-w 6.0)            ; אורך הקו לפי כלל הכותרת — רוחב הטקסט + 3 יחידות מכל צד
        text-x   (+ lx (* 0.5 line-len))  ; טקסט ממורכז מעל הקו
        top-y    (+ ly gap txt-h)         ; הטקסט מעל הקו
        near-pt  (list lx line-y))        ; הלידרים מתחברים לקצה השמאלי
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
  (cdt:draw-line near-pt (list (+ lx line-len) line-y) layer)
  (entmake
    (list (cons 0  "TEXT")
          (cons 8  layer)
          (cons 62 (if (and txt-color (not (equal txt-color ""))) (cdt-sint txt-color) 256))
          (cons 10 (list text-x top-y 0.0))
          (cons 40 txt-h)
          (cons 1  txt)
          (cons 50 0.0)
          (cons 7  use-style)
          (cons 72 1)
          (cons 73 3)
          (cons 11 (list text-x top-y 0.0))))
  (if edge1 (cdt:draw-line edge1 near-pt layer))
  (if edge2 (cdt:draw-line edge2 near-pt layer))
  (command "_.COLOR" "BYLAYER"))

(defun cdt:draw-spiral-block (touch-pt conn-pt dir fields layer leader-color
                               txt-style txt-height txt-color /
                               txt lx ly line-y txt-h gap tb txt-w line-len
                               far-x text-cx text-y use-style ins-pt)
  ; בלוק ספירלה: לידר נוגע במעגל הפנימי (touch-pt) → קו תחתון → טקסט מעליו דרך
  ; bars:draw-label (קריאה בלבד ל-BARS). conn-pt = הקצה שאליו מתחבר הלידר (הקרוב למעגל).
  ; dir=+1 → הקו נמתח ימינה (כמו בלוק הדונאטים); dir=-1 → שמאלה (תמונת מראה).
  (setq txt    (if *cdt-bars-ok* (bars:build-label-text fields) "")
        lx     (car  conn-pt)
        ly     (cadr conn-pt)
        txt-h  (if (and txt-height (> txt-height 0.0)) txt-height 2.5)
        gap    1.0
        line-y ly)
  (setq use-style
    (cond
      ((and txt-style (not (equal txt-style "")) (tblsearch "STYLE" txt-style)) txt-style)
      ((tblsearch "STYLE" "OPHER") "OPHER")
      (t "Standard")))
  (setq tb (vl-catch-all-apply 'textbox
              (list (list (cons 0 "TEXT") (cons 1 txt) (cons 40 txt-h) (cons 7 use-style)))))
  (setq txt-w (if (and tb (not (vl-catch-all-error-p tb)) (listp tb) (listp (cadr tb)))
                (car (cadr tb))
                (* (strlen txt) txt-h 0.6))
        line-len (+ txt-w 6.0)                ; רוחב הטקסט + 3 יח' מכל צד
        far-x    (+ lx (* dir line-len))      ; הקצה הרחוק של הקו (לפי הכיוון)
        text-cx  (+ lx (* dir 0.5 line-len))  ; מרכז הטקסט
        text-y   (+ ly gap)                   ; בסיס הטקסט צמוד מעל הקו (כמו בלוק הדונאטים)
        ins-pt   (list (- text-cx (* 0.5 txt-w)) text-y))   ; שמאל הטקסט → ממורכז על הקו
  (if *cdt-bars-ok* (bars:ensure-opher-style))
  ;; קווים — לידר וקו תחתון
  (command "_.COLOR" (if (and leader-color (not (equal leader-color ""))) leader-color "BYLAYER"))
  (cdt:draw-line (list lx line-y) (list far-x line-y) layer)   ; קו תחתון
  (cdt:draw-line touch-pt (list lx line-y) layer)              ; לידר למעגל הפנימי
  (command "_.COLOR" "BYLAYER")
  ;; טקסט — דרך BARS (קריאה בלבד; הקידומת "ספירלה" היא נתון, לא עריכת קוד)
  (if *cdt-bars-ok*
    (progn
      (setvar "CECOLOR" (if (and txt-color (not (equal txt-color ""))) (cdt:color-str txt-color) "256"))
      ;; style=nil → OPHER (default) ; color passed explicitly (ACI string)
      (bars:draw-label ins-pt fields (bars:make-id) "" layer txt-h 0
                       nil
                       (if (and txt-color (not (equal txt-color "")))
                         (cdt:color-str txt-color) nil))
      (setvar "CECOLOR" "256"))))

;; ── חלון "ספירלה" — חלון משלנו ב-COLDET (כדי שהכותרת תהיה "ספירלה" ולא
;;    "חישוקים", ובלי שדה כמות). עברית כ-octal Windows-1255. לא נוגע ב-BARS.
(defun cdt:spiral-dialog (/ tlabels tchars diams path dlg-id
                            btype-idx diam-idx spac)
  ; משתמש בקובץ DCL קבוע (coldet_spiral.dcl, קידוד Windows-1255) — כך העברית
  ; מובטחת, במקום כתיבת קובץ זמני עם קודי אוקטל שלא נקראים נכון מ-UTF-8-with-BOM.
  (setq tlabels (list "1" "2" "3" "4")
        tchars  (list "%%157" "%%156" "%%158" "%%159")   ; סוגים 1↔2 הוחלפו
        diams   (list "6" "8" "10" "12" "14" "16" "18" "20"
                      "22" "24" "26" "28" "30" "32" "34" "36" "38" "40")
        path    (strcat (cdt:lsp-dir) "\\coldet_spiral.dcl")
        *cdt-spiral-ok* nil)
  (if (null (findfile path)) nil
    (progn
      (setq dlg-id (load_dialog path))
      (if (or (null dlg-id) (not (numberp dlg-id)) (< dlg-id 0)) nil
        (if (not (new_dialog "coldet_spiral" dlg-id))
          (progn (unload_dialog dlg-id) nil)
          (progn
            (start_list "btype") (foreach tt tlabels (add_list tt)) (end_list)
            (start_list "diam")  (foreach d diams (add_list d)) (end_list)
            (set_tile "btype" "0")
            (set_tile "diam"  (itoa (cdt:list-index diams "8")))
            (set_tile "spac"  "20")
            (action_tile "sp_ok"
              "(setq *cdt-spiral-ok* T *csd-btype* (get_tile \"btype\") *csd-diam* (get_tile \"diam\") *csd-spac* (get_tile \"spac\"))(done_dialog 0)")
            (action_tile "sp_cancel" "(done_dialog 0)")
            (start_dialog)
            (unload_dialog dlg-id)
            (if *cdt-spiral-ok*
              (progn
                (setq btype-idx (atoi *csd-btype*)
                      diam-idx  (atoi *csd-diam*)
                      spac      *csd-spac*)
                (list (nth btype-idx tchars) (nth diam-idx diams) spac))
              nil)))))))

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
;;; F3. מנוע צורה מורכבת — "קוסטום"
;;; ============================================================
;;; המשתמש בוחר את מתאר העמוד (עותק מדויק) ובנפרד מסמן מלבנים
;;; שמגדירים את הזיון והמידות. הפונקציות כאן מחשבות את מתאר
;;; האיחוד של המלבנים בשיטת "רשת" מספרית (בלי פקודות איחוד של הקאד),
;;; ומהמתאר גוזרות דונאטים, קו כיסוי פנימי וקווי מידה.

(defun cu:pt-eq (a b)
  ; השוואת שתי נקודות בטולרנס קטן
  (and (< (abs (- (car a)  (car b)))  1e-6)
       (< (abs (- (cadr a) (cadr b))) 1e-6)))

(defun cu:insert-sorted (x lst)
  ; הכנסת מספר לרשימה ממוינת (עולה)
  (cond
    ((null lst) (list x))
    ((<= x (car lst)) (cons x lst))
    (t (cons (car lst) (cu:insert-sorted x (cdr lst))))))

(defun cu:num-sort (lst / res x)
  (setq res nil)
  (foreach x lst (setq res (cu:insert-sorted x res)))
  res)

(defun cu:sort-uniq (lst / res dup x y)
  ; מיון עולה + הסרת כפילויות (בלי vl-sort — בטוח ל-ZWCAD)
  (setq res nil)
  (foreach x lst
    (setq dup nil)
    (foreach y res (if (< (abs (- x y)) 1e-6) (setq dup T)))
    (if (not dup) (setq res (cons x res))))
  (cu:num-sort res))

(defun cu:pt-in-rect (pt r)
  ; נקודה בתוך מלבן (בדיקה חמורה — משמש למרכזי תאים שלעולם לא על הקצה)
  (and (> (car pt)  (car r))   (< (car pt)  (caddr r))
       (> (cadr pt) (cadr r))  (< (cadr pt) (cadddr r))))

(defun cu:pt-in-any (pt rects / hit r)
  (setq hit nil)
  (foreach r rects (if (cu:pt-in-rect pt r) (setq hit T)))
  hit)

(defun cu:union-segs (rects / xs ys nx ny i j midx midy lin rin bin ain segs r)
  ; מחזיר רשימת קטעי-גבול (כל קטע = (p q)) של איחוד המלבנים.
  ; בונה רשת מכל קווי ה-X/Y, ובודק לכל תא אם מרכזו בתוך הצורה.
  (setq xs nil ys nil)
  (foreach r rects
    (setq xs (cons (car r) (cons (caddr r) xs))
          ys (cons (cadr r) (cons (cadddr r) ys))))
  (setq xs (cu:sort-uniq xs)  ys (cu:sort-uniq ys)
        nx (length xs)  ny (length ys)  segs nil)
  ;; קטעים אנכיים: על x=xs[i], XOR בין תא שמאלי (i-1) לימני (i)
  (setq i 0)
  (while (< i nx)
    (setq j 0)
    (while (< j (1- ny))
      (setq midy (* 0.5 (+ (nth j ys) (nth (1+ j) ys)))
            lin  (and (> i 0)
                      (cu:pt-in-any (list (* 0.5 (+ (nth (1- i) xs) (nth i xs))) midy) rects))
            rin  (and (< i (1- nx))
                      (cu:pt-in-any (list (* 0.5 (+ (nth i xs) (nth (1+ i) xs))) midy) rects)))
      (if (not (eq (not lin) (not rin)))
        (setq segs (cons (list (list (nth i xs) (nth j ys))
                               (list (nth i xs) (nth (1+ j) ys))) segs)))
      (setq j (1+ j)))
    (setq i (1+ i)))
  ;; קטעים אופקיים: על y=ys[j], XOR בין תא תחתון (j-1) לעליון (j)
  (setq j 0)
  (while (< j ny)
    (setq i 0)
    (while (< i (1- nx))
      (setq midx (* 0.5 (+ (nth i xs) (nth (1+ i) xs)))
            bin  (and (> j 0)
                      (cu:pt-in-any (list midx (* 0.5 (+ (nth (1- j) ys) (nth j ys)))) rects))
            ain  (and (< j (1- ny))
                      (cu:pt-in-any (list midx (* 0.5 (+ (nth j ys) (nth (1+ j) ys)))) rects)))
      (if (not (eq (not bin) (not ain)))
        (setq segs (cons (list (list (nth i xs) (nth j ys))
                               (list (nth (1+ i) xs) (nth j ys))) segs)))
      (setq i (1+ i)))
    (setq j (1+ j)))
  segs)

(defun cu:merge-collinear (pts / n res i a b c)
  ; מסיר קודקודי-ביניים הנמצאים על אותו קו ישר (אופקי/אנכי)
  (setq n (length pts) res nil i 0)
  (while (< i n)
    (setq a (nth (rem (+ i (1- n)) n) pts)
          b (nth i pts)
          c (nth (rem (1+ i) n) pts))
    (if (not (or (and (< (abs (- (car a) (car b))) 1e-6) (< (abs (- (car b) (car c))) 1e-6))
                 (and (< (abs (- (cadr a) (cadr b))) 1e-6) (< (abs (- (cadr b) (cadr c))) 1e-6))))
      (setq res (cons b res)))
    (setq i (1+ i)))
  (reverse res))

(defun cu:trace-loops (segs / pool loops seg start cur nxt found keep pts s)
  ; מפרק את קטעי-הגבול ללולאות סגורות ומסודרות; ממזג קודקודים קולינאריים.
  ; מניח מרכיב פשוט (דרגה 2 בכל קודקוד) — טיפוסי לעמוד.
  (setq pool segs loops nil)
  (while pool
    (setq seg   (car pool)  pool (cdr pool)
          start (car seg)   cur  (cadr seg)
          pts   (list start))
    (while (and cur (not (cu:pt-eq cur start)))
      (setq pts (cons cur pts) found nil keep nil)
      (foreach s pool
        (if (and (not found)
                 (or (cu:pt-eq (car s) cur) (cu:pt-eq (cadr s) cur)))
          (setq found s
                nxt (if (cu:pt-eq (car s) cur) (cadr s) (car s)))
          (setq keep (cons s keep))))
      (if found (setq pool keep  cur nxt) (setq cur nil)))
    (if (> (length pts) 2)
      (setq loops (cons (cu:merge-collinear (reverse pts)) loops))))
  loops)

(defun cu:poly-area (pts / n i a b s)
  (setq n (length pts) s 0.0 i 0)
  (while (< i n)
    (setq a (nth i pts) b (nth (rem (1+ i) n) pts)
          s (+ s (- (* (car a) (cadr b)) (* (car b) (cadr a)))))
    (setq i (1+ i)))
  (* 0.5 s))

(defun cu:ccw (pts)
  ; מחזיר את הקודקודים בכיוון נגד-השעון (שטח חתום חיובי)
  (if (< (cu:poly-area pts) 0.0) (reverse pts) pts))

(defun cu:inset-poly (pts d / n edges i a b dx dy res prevE curE)
  ; הזחת מצולע מלבני (צלעות מקבילות לצירים) פנימה ב-d. pts מנורמלים ל-CCW.
  (setq pts (cu:ccw pts)  n (length pts)  edges nil  i 0)
  (while (< i n)
    (setq a (nth i pts)  b (nth (rem (1+ i) n) pts)
          dx (- (car b) (car a))  dy (- (cadr b) (cadr a)))
    (if (< (abs dy) 1e-6)
      (setq edges (cons (list 'H (+ (cadr a) (* d (if (> dx 0) 1.0 -1.0)))) edges))   ; אופקית → y'
      (setq edges (cons (list 'V (- (car a) (* d (if (> dy 0) 1.0 -1.0)))) edges)))   ; אנכית  → x'
    (setq i (1+ i)))
  (setq edges (reverse edges)  res nil  i 0)
  (while (< i n)
    (setq prevE (nth (rem (+ i (1- n)) n) edges)  curE (nth i edges))
    (if (eq (car prevE) 'H)
      (setq res (cons (list (cadr curE)  (cadr prevE)) res))    ; x מהצלע האנכית, y מהאופקית
      (setq res (cons (list (cadr prevE) (cadr curE))  res)))
    (setq i (1+ i)))
  (reverse res))

(defun cu:draw-poly (pts layer / prev p)
  ; מצייר פוליליין סגור מרשימת קודקודים (מכבד CECOLOR שנקבע בחוץ)
  (cdt:ensure-layer layer)
  (setq prev (getvar "CLAYER"))
  (setvar "CLAYER" layer)
  (command "_.PLINE")
  (foreach p pts (command (list (car p) (cadr p))))
  (command "_Close")
  (setvar "CLAYER" prev)
  (entlast))

(defun cu:poly-donuts (pts size layer placed / n i a b)
  ; דונאט בכל קודקוד + מילוי לאורך כל צלע (עם מעקב כדי למנוע כפילויות)
  (setq n (length pts) i 0)
  (while (< i n)
    (setq placed (cdt:donut-if-new (nth i pts) size layer placed) i (1+ i)))
  (setq i 0)
  (while (< i n)
    (setq a (nth i pts) b (nth (rem (1+ i) n) pts)
          placed (cdt:fill-pts a b size layer placed) i (1+ i)))
  placed)

(defun cu:external-p (pt odx ody rects dist / probe hit)
  ; הצלע חיצונית אם נקודת-בדיקה (צעד קטן החוצה בכיוון (odx,ody)) אינה בתוך אף מלבן
  (setq probe (list (+ (car pt) (* odx dist)) (+ (cadr pt) (* ody dist)))
        hit nil)
  (foreach r rects (if (cu:pt-in-rect probe r) (setq hit T)))
  (not hit))

(defun cu:edge-donuts-filtered (a b odx ody rects dist size layer placed / len n i tp p)
  ; דונאטים על הקטע a..b (כולל הקצוות) במרווח אחיד, רק היכן שהצלע חיצונית
  (setq len (cdt:dist2d a b)
        n   (cdt:ceiling-int (/ len CDT:MAX-SPACING))
        i 0)
  (while (<= i n)
    (setq tp (if (= n 0) 0.0 (/ (* 1.0 i) n))
          p  (cdt:lerp a b tp))
    (if (cu:external-p p odx ody rects dist)
      (setq placed (cdt:donut-if-new p size layer placed)))
    (setq i (1+ i)))
  placed)

(defun cu:gap-fill (placed rects size ins layer / ys xs yv xv rowx rowy prev nseg k pos p
                    mx my ua da um dm la ra lm rm)
  ; מילוי מרווחים: בין 2 דונאטים סמוכים על אותו קו (אופקי/אנכי) שהמרחק > CDT:MAX-SPACING,
  ; מוסיף דונאטים המחלקים לחלקים שווים — אך **רק אם הקו הוא פאה חיצונית**
  ; (חומר בצד אחד, אוויר בצד השני). קו פנימי (חומר משני הצדדים) לא מתמלא.
  ;; מעבר אופקי — לכל קו y
  (setq ys (cu:sort-uniq (mapcar 'cadr placed)))
  (foreach yv ys
    (setq rowx nil)
    (foreach p placed (if (< (abs (- (cadr p) yv)) 0.1) (setq rowx (cons (car p) rowx))))
    (setq rowx (cu:sort-uniq rowx) prev nil)
    (foreach xv rowx
      (if (and prev (> (- xv prev) CDT:MAX-SPACING))
        (progn
          (setq mx (* 0.5 (+ prev xv))
                ua (not (cu:pt-in-any (list mx (+ yv ins 1.0)) rects))   ; אוויר מעל הפאה?
                da (not (cu:pt-in-any (list mx (- yv ins 1.0)) rects))   ; אוויר מתחת לפאה?
                um (cu:pt-in-any (list mx (+ yv 1.0)) rects)             ; חומר מעל הקו?
                dm (cu:pt-in-any (list mx (- yv 1.0)) rects))            ; חומר מתחת לקו?
          (if (or (and dm ua) (and um da))   ; פאה חיצונית: חומר בצד אחד, אוויר בשני
            (progn
              (setq nseg (cdt:ceiling-int (/ (- xv prev) CDT:MAX-SPACING)) k 1)
              (while (< k nseg)
                (setq pos (list (+ prev (* (/ (* 1.0 k) nseg) (- xv prev))) yv)
                      placed (cdt:donut-if-new pos size layer placed) k (1+ k)))))))
      (setq prev xv)))
  ;; מעבר אנכי — לכל קו x
  (setq xs (cu:sort-uniq (mapcar 'car placed)))
  (foreach xv xs
    (setq rowy nil)
    (foreach p placed (if (< (abs (- (car p) xv)) 0.1) (setq rowy (cons (cadr p) rowy))))
    (setq rowy (cu:sort-uniq rowy) prev nil)
    (foreach yv rowy
      (if (and prev (> (- yv prev) CDT:MAX-SPACING))
        (progn
          (setq my (* 0.5 (+ prev yv))
                la (not (cu:pt-in-any (list (- xv ins 1.0) my) rects))  ; אוויר משמאל לפאה?
                ra (not (cu:pt-in-any (list (+ xv ins 1.0) my) rects))  ; אוויר מימין לפאה?
                lm (cu:pt-in-any (list (- xv 1.0) my) rects)            ; חומר משמאל לקו?
                rm (cu:pt-in-any (list (+ xv 1.0) my) rects))           ; חומר מימין לקו?
          (if (or (and rm la) (and lm ra))   ; פאה חיצונית אנכית
            (progn
              (setq nseg (cdt:ceiling-int (/ (- yv prev) CDT:MAX-SPACING)) k 1)
              (while (< k nseg)
                (setq pos (list xv (+ prev (* (/ (* 1.0 k) nseg) (- yv prev))))
                      placed (cdt:donut-if-new pos size layer placed) k (1+ k)))))))
      (setq prev yv)))
  placed)

(defun cu:tie-donuts (rects size offset layer placed / dinset ins bi c r lp)
  ; לוגיקת הדונאטים לצורת קוסטום (לפי הכלל שהוכתב):
  ;  1) צור דונאט בכל פינה של כל מלבן פנימי (מוקטן ב-offset+dinset) — כולל צמתים.
  ;  1ב) דונאט בכל קודקוד של מתאר האיחוד המוזח פנימה — מכסה פינות קעורות בין מלבנים.
  ;  2) מחק כפילויות (פינות מתלכדות) — donut-if-new אוטומטי.
  ;  3+4) בין כל 2 דונאטים סמוכים על אותו קו שהמרווח ביניהם > CDT:MAX-SPACING — הוסף דונאטים
  ;     שמחלקים לחלקים שווים (רק אם הקטע בחומר). מכסה היקף חיצוני וקווים פנימיים.
  (setq dinset (* 0.8 size)   ; מרחק הדונאט מקו הכיסוי הפנימי (היה 1.2 — הוקטן לקירוב)
        ins    (+ offset dinset))
  (foreach r rects
    (setq bi (cdt:bbox-inset r ins))
    (foreach c (cdt:bbox-corners bi)
      (setq placed (cdt:donut-if-new c size layer placed))))
  (foreach lp (mapcar 'cu:ccw (cu:trace-loops (cu:union-segs rects)))
    (foreach c (cu:inset-poly lp ins)
      (setq placed (cdt:donut-if-new c size layer placed))))
  (setq placed (cu:gap-fill placed rects size ins layer))
  placed)

(defun cu:overlap-donuts (rects offset size layer placed / n i j ri rj ov)
  ; דונאטים בפינות אזורי החפיפה בין כל זוג מלבנים — כמו ח'/זי/ר'.
  ; משלים את הזיון בצמתים הפנימיים (שם הצלעות החיצוניות נגמרות).
  (setq n (length rects) i 0)
  (while (< i (1- n))
    (setq ri (cdt:bbox-inset (nth i rects) offset) j (1+ i))
    (while (< j n)
      (setq rj (cdt:bbox-inset (nth j rects) offset)
            ov (cdt:bbox-intersect ri rj))
      (if (and (> (- (caddr ov)  (car ov))  (* 0.5 size))
               (> (- (cadddr ov) (cadr ov)) (* 0.5 size)))
        (setq placed (cdt:place-corner-donuts-tracked ov size layer placed)))
      (setq j (1+ j)))
    (setq i (1+ i)))
  placed)

;;; ── מידות קוסטום — 4 פאות, כל פאה נשברת לפי הפרופיל של הקו שלה ──

(defun cu:cell-in (rects xs ys i j)
  ; האם מרכז התא (i,j) ברשת בתוך החומר
  (cu:pt-in-any (list (* 0.5 (+ (nth i xs) (nth (1+ i) xs)))
                      (* 0.5 (+ (nth j ys) (nth (1+ j) ys)))) rects))

(defun cu:col-level (rects xs ys ny i is-bottom / j found lvl)
  ; רמת ה-y של הפרופיל התחתון (is-bottom=T) או העליון בעמודת-x מס' i; nil אם ריק
  (setq found nil lvl nil)
  (if is-bottom
    (progn (setq j 0)
      (while (and (< j (1- ny)) (not found))
        (if (cu:cell-in rects xs ys i j) (setq found T lvl (nth j ys)))
        (setq j (1+ j))))
    (progn (setq j (- ny 2))
      (while (and (>= j 0) (not found))
        (if (cu:cell-in rects xs ys i j) (setq found T lvl (nth (1+ j) ys)))
        (setq j (1- j)))))
  lvl)

(defun cu:row-level (rects xs ys nx j is-left / i found lvl)
  ; רמת ה-x של הפרופיל השמאלי (is-left=T) או הימני בשורת-y מס' j; nil אם ריק
  (setq found nil lvl nil)
  (if is-left
    (progn (setq i 0)
      (while (and (< i (1- nx)) (not found))
        (if (cu:cell-in rects xs ys i j) (setq found T lvl (nth i xs)))
        (setq i (1+ i))))
    (progn (setq i (- nx 2))
      (while (and (>= i 0) (not found))
        (if (cu:cell-in rects xs ys i j) (setq found T lvl (nth (1+ i) xs)))
        (setq i (1- i)))))
  lvl)

(defun cu:closer (a b use-min)
  ; הרמה הקרובה יותר לקו המידה: min לפאה תחתונה/שמאלית, max לעליונה/ימנית
  (if use-min (min a b) (max a b)))

(defun cu:collect-runs (rects xs ys nx ny is-h is-lo / i m lvl runs cur-lvl cur-0 c0 c1)
  ; אוסף ריצות של רמה קבועה לאורך הפאה. מחזיר רשימת (coord0 coord1 level).
  ; is-h=T → פאה אופקית (רץ על עמודות x); is-lo=T → תחתונה/שמאלית.
  (setq m (if is-h nx ny) runs nil cur-lvl nil cur-0 nil i 0)
  (while (< i (1- m))
    (setq lvl (if is-h (cu:col-level rects xs ys ny i is-lo)
                       (cu:row-level rects xs ys nx i is-lo))
          c0  (nth i (if is-h xs ys)))
    (if (not (and cur-lvl lvl (equal lvl cur-lvl 1e-6)))
      (progn
        (if cur-lvl (setq runs (cons (list cur-0 c0 cur-lvl) runs)))
        (if lvl (setq cur-lvl lvl cur-0 c0) (setq cur-lvl nil cur-0 nil))))
    (setq i (1+ i)))
  (if cur-lvl (setq runs (cons (list cur-0 (nth (1- m) (if is-h xs ys)) cur-lvl) runs)))
  (reverse runs))

(defun cu:dim-hchain (rects xs ys nx ny bb dim-off is-bottom / refy runs n k r rl rr)
  ; שרשרת אופקית: כל שבירה (משותפת לשתי מדרגות) משתמשת ברמה הקרובה לקו המידה
  (setq refy (if is-bottom (- (cadr bb) dim-off) (+ (cadddr bb) dim-off))
        runs (cu:collect-runs rects xs ys nx ny T is-bottom)
        n (length runs) k 0)
  (while (< k n)
    (setq r  (nth k runs)
          rl (if (and (> k 0) (equal (car r) (cadr (nth (1- k) runs)) 1e-6))
               (cu:closer (caddr (nth (1- k) runs)) (caddr r) is-bottom) (caddr r))
          rr (if (and (< k (1- n)) (equal (cadr r) (car (nth (1+ k) runs)) 1e-6))
               (cu:closer (caddr (nth (1+ k) runs)) (caddr r) is-bottom) (caddr r)))
    (command "_.DIMLINEAR" (list (car r) rl) (list (cadr r) rr)
      (list (* 0.5 (+ (car r) (cadr r))) refy))
    (setq k (1+ k))))

(defun cu:dim-vchain (rects xs ys nx ny bb dim-off is-left / refx runs n k r rl rr)
  ; שרשרת אנכית: כל שבירה משתמשת ברמה (x) הקרובה לקו המידה
  (setq refx (if is-left (- (car bb) dim-off) (+ (caddr bb) dim-off))
        runs (cu:collect-runs rects xs ys nx ny nil is-left)
        n (length runs) k 0)
  (while (< k n)
    (setq r  (nth k runs)
          rl (if (and (> k 0) (equal (car r) (cadr (nth (1- k) runs)) 1e-6))
               (cu:closer (caddr (nth (1- k) runs)) (caddr r) is-left) (caddr r))
          rr (if (and (< k (1- n)) (equal (cadr r) (car (nth (1+ k) runs)) 1e-6))
               (cu:closer (caddr (nth (1+ k) runs)) (caddr r) is-left) (caddr r)))
    (command "_.DIMLINEAR" (list rl (car r)) (list rr (cadr r))
      (list refx (* 0.5 (+ (car r) (cadr r)))))
    (setq k (1+ k))))

(defun cu:dimensions (rects bb dim-off / xs ys nx ny r)
  ; מידה על 4 הפאות; כל פאה נשברת לפי מדרגות הפרופיל של הקו שלה בלבד.
  (setq xs nil ys nil)
  (foreach r rects
    (setq xs (cons (car r) (cons (caddr r) xs))
          ys (cons (cadr r) (cons (cadddr r) ys))))
  (setq xs (cu:sort-uniq xs) ys (cu:sort-uniq ys)
        nx (length xs) ny (length ys))
  (cu:dim-hchain rects xs ys nx ny bb dim-off T)     ; פאה תחתונה
  (cu:dim-hchain rects xs ys nx ny bb dim-off nil)   ; פאה עליונה
  (cu:dim-vchain rects xs ys nx ny bb dim-off T)     ; פאה שמאלית
  (cu:dim-vchain rects xs ys nx ny bb dim-off nil)   ; פאה ימנית
  (princ))

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
                   ls-sx0 ls-sy1 ls-sbb1 ls-sx0-2 ls-sy2 ls-sbb2 ls-stir-vals
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
                   ent-before blk-ss blk-e blk-name blk-base ins-pt ins-ent
                   dlg-start ldir start-code cfg-saved shape-kw
                   ch-dec ch-bb ch-rects rc
                   ch-beam ch-lA ch-lB ch-bcen ch-ov1 ch-ov2
                   ch-r1 ch-r2 ch-aof ch-arx ch-aif ch-bof ch-brx ch-bif
                   ch-mark ch-ext ch-maxx ch-maxy ch-sgap ch-sdx ch-sbb srect ch-stir-vals
                   cir-cen cir-r cir-ir cir-rr cir-gap cir-n cir-i cir-ang cir-pt
                   cir-int-ent c-bb c-ext cl-e1 cl-e2
                   sp-vals sp-type sp-diam sp-spac sp-fields sp-th sp-touch sp-conn
                   cu-rects cu-more cu-p1 cu-p2 cu-ans cu-bb cu-loops lp
                   cu-mark cu-ext cu-maxx cu-maxy cu-sx cu-w cu-h cu-sbb cu-stir-vals
                   t-horiz t-stem-full t-flange-in t-stem-in
                   t-ov t-ov-inset t-ov-cen t-ov-bl t-ov-br t-ov-tr t-ov-tl
                   t-e1 t-e1-inset t-e1-cen t-e1-p1 t-e1-p2
                   t-e2 t-e2-inset t-e2-cen t-e2-p1 t-e2-p2
                   t-ext t-ext-inset t-ext-cen t-ext-p1 t-ext-p2 t-anch1 t-anch2)
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
     (initget "REC L T Z U CIR CUSTOM")
     (setq shape-kw (getkword "\nShape type [REC/L/T/Z/U/CIR/CUSTOM] <REC>: "))
     (if (null shape-kw) (setq shape-kw "REC"))   ; Enter = ריבוע
     (setq shape (cond ((= shape-kw "REC") "rect")
                       ((= shape-kw "L")   "lshape")
                       ((= shape-kw "T")   "tshape")
                       ((= shape-kw "Z")   "zshape")
                       ((= shape-kw "U")   "chet")
                       ((= shape-kw "CIR") "circle")
                       ((= shape-kw "CUSTOM") "custom")))
     (cdt:log (strcat "[L01] shape=" shape " (kw=" shape-kw ")"))

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
             (if (and (cdt:get cfg "dim-style")
                      (not (equal (cdt:get cfg "dim-style") "")))
               (if (tblsearch "DIMSTYLE" (cdt:get cfg "dim-style"))
                 (command "_.DIMSTYLE" "R" (cdt:get cfg "dim-style") "")
                 (princ (strcat "\nWarning: dim-style '" (cdt:get cfg "dim-style") "' not found."))))
             ;; אחרי שחזור הסגנון — קנה המידה מההגדרות גובר (אחרת הסגנון דורס אותו)
             (setvar "DIMSCALE" (atof (cdt:get cfg "dim-scale")))
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
             (setq bar-conn-pt (cdt:bar-block-conn-pt bb-ext cfg)
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
             (cdt:log "[L60] circle-path")
             ;; אימות — רשת ביטחון; המשתמש כבר הצהיר "עיגול"
             (if (/= (cdr (assoc 0 (entget ename))) "CIRCLE")
               (progn (setvar "OSMODE" prev-osmode)
                      (princ "\nError: selected entity is not a CIRCLE.") (exit)))
             (setq cir-cen (cdr (assoc 10 (entget ename)))
                   cir-cen (list (car cir-cen) (cadr cir-cen))   ; x,y בלבד
                   cir-r   (cdr (assoc 40 (entget ename)))
                   cir-ir  (- cir-r offset)                      ; רדיוס פנימי (כיסוי)
                   cir-gap (* 1.2 donut-size)
                   cir-rr  (- cir-ir cir-gap)                    ; רדיוס מעגל הזיון
                   c-bb    (list (- (car cir-cen) cir-r) (- (cadr cir-cen) cir-r)
                                 (+ (car cir-cen) cir-r) (+ (cadr cir-cen) cir-r))
                   ch-mark (entlast))   ; סמן לפני ציור — למדידת גבול אמיתי

             ;; איפוס סוג-קו וקנה-מידה נוכחיים — מונע "דליפת" CENTER מריצה קודמת
             ;; לישויות הבאות (מידות, גיאומטריה פנימית)
             (setvar "CELTYPE"   "BYLAYER")
             (setvar "CELTSCALE" 1.0)

             ;; גיאומטריה חיצונית — העתק הישות
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "ext-color")))
             (command "_.COPY" (ssadd ename (ssadd)) "" '(0 0 0) '(0 0 0))
             (cdt:set-layer (entlast) (cdt:get cfg "ext-layer"))
             (setvar "CECOLOR" "256")
             ;; שני קווי ציר (+) — אורך 1.4× הקוטר (20% מעבר לכל כיוון).
             ;; סוג CENTER ו-LTScale 1 נקבעים ישירות על הישות (cdt:set-center-lt),
             ;; בלי לגעת ב-CELTYPE הגלובלי → אין דליפה למידות/לגיאומטריה הפנימית.
             ;; צבע ושכבה — כמו הלידרים.
             (cdt:ensure-linetype "CENTER")
             (command "_.COLOR" (cdt:color-str (cdt:get cfg "leader-color")))
             (setq cl-e1 (cdt:draw-line
                           (list (- (car cir-cen) (* 1.4 cir-r)) (cadr cir-cen))
                           (list (+ (car cir-cen) (* 1.4 cir-r)) (cadr cir-cen))
                           (cdt:get cfg "leader-layer"))
                   cl-e2 (cdt:draw-line
                           (list (car cir-cen) (- (cadr cir-cen) (* 1.4 cir-r)))
                           (list (car cir-cen) (+ (cadr cir-cen) (* 1.4 cir-r)))
                           (cdt:get cfg "leader-layer")))
             (command "_.COLOR" "BYLAYER")
             (cdt:set-center-lt cl-e1)
             (cdt:set-center-lt cl-e2)

             ;; ── מידה חיצונית — קו מידה רגיל (קוטר), מתחת
             (cdt:log "[L60b] circle-dim-ext")
             (setq prev-dimscale (getvar "DIMSCALE")
                   dim-prev-lay  (getvar "CLAYER")
                   dim-off       CDT:DIM-OFFSET)
             (cdt:ensure-layer (cdt:get cfg "dim-layer"))
             (setvar "CLAYER"   (cdt:get cfg "dim-layer"))
             (setvar "CECOLOR"  (cdt:color-str (cdt:get cfg "dim-color")))
             (if (and (cdt:get cfg "dim-style")
                      (not (equal (cdt:get cfg "dim-style") "")))
               (if (tblsearch "DIMSTYLE" (cdt:get cfg "dim-style"))
                 (command "_.DIMSTYLE" "R" (cdt:get cfg "dim-style") "")
                 (princ (strcat "\nWarning: dim-style '" (cdt:get cfg "dim-style") "' not found."))))
             ;; אחרי שחזור הסגנון — קנה המידה מההגדרות גובר (אחרת הסגנון דורס אותו)
             (setvar "DIMSCALE" (atof (cdt:get cfg "dim-scale")))
             (command "_.DIMLINEAR"
               (list (- (car cir-cen) cir-r) (cadr cir-cen))
               (list (+ (car cir-cen) cir-r) (cadr cir-cen))
               (list (car cir-cen) (- (cadr cir-cen) cir-r dim-off 4.0)))
             (setvar "CLAYER"   dim-prev-lay)
             (setvar "CECOLOR"  "256")
             (setvar "DIMSCALE" prev-dimscale)

             ;; גיאומטריה פנימית
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "int-color")))
             (setq cir-int-ent (cdt:draw-circle cir-cen cir-ir (cdt:get cfg "int-layer")))
             (setvar "CECOLOR" "256")

             ;; ── מידה פנימית — קו מידה רגיל, בצד מנגד (מעל)
             (cdt:log "[L60c] circle-dim-int")
             (setvar "CLAYER"   (cdt:get cfg "dim-layer"))
             (setvar "CECOLOR"  (cdt:color-str (cdt:get cfg "dim-color")))
             (setvar "DIMSCALE" (atof (cdt:get cfg "dim-scale")))
             (command "_.DIMLINEAR"
               (list (- (car cir-cen) cir-ir) (cadr cir-cen))
               (list (+ (car cir-cen) cir-ir) (cadr cir-cen))
               (list (car cir-cen) (+ (cadr cir-cen) cir-r dim-off)))
             (setvar "CLAYER"   dim-prev-lay)
             (setvar "CECOLOR"  "256")
             (setvar "DIMSCALE" prev-dimscale)

             ;; ── דונאטים — מספר אוטומטי לפי מרווח, אחיד על מעגל הזיון
             (cdt:log "[L61] circle-donuts")
             (setq cir-n (cdt:ceiling-int (/ (* 2.0 pi cir-rr) CDT:MAX-SPACING)))
             (if (< cir-n 6) (setq cir-n 6))
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "donut-color")))
             (setq placed nil  cir-i 0)
             (while (< cir-i cir-n)
               (setq cir-ang (+ (* 0.5 pi) (/ (* 2.0 pi cir-i) cir-n))   ; התחלה למעלה
                     cir-pt  (polar cir-cen cir-ang cir-rr)
                     placed  (cdt:donut-if-new cir-pt donut-size donut-layer placed)
                     cir-i   (1+ cir-i)))
             (setvar "CECOLOR" "256")
             (cdt:log (strcat "[L62] circle-donuts-done placed=" (itoa (length placed))))

             ;; ── גבול אמיתי של מה שצויר (כולל מידות)
             (setq c-ext   (cdt:ents-bbox-max ch-mark)
                   ch-maxx (car  c-ext)
                   ch-maxy (cadr c-ext))
             (if (null ch-maxx) (setq ch-maxx (caddr  c-bb)))
             (if (null ch-maxy) (setq ch-maxy (cadddr c-bb)))

             ;; גובה טקסט הבלוקים; שני הבלוקים בגובה המרכז כדי שהלידרים לא יחצו
             ;; את המידה התחתונה. הקו ב-cy+4 → תחתית הטקסט ~5 יח' מעל המרכז.
             (setq sp-th (atof (cdt:get cfg "donut-txt-height"))
                   sp-th (if (> sp-th 0.0) sp-th 2.5)
                   bar-conn-pt (list (+ (caddr c-bb) (* 1.5 sp-th))
                                     (+ (cadr cir-cen) 4.0)))

             ;; ── חישוק = ספירלה: לידר נוגע במעגל הפנימי + קו תחתון + טקסט מ-BARS,
             ;;    בתמונת מראה לבלוק הדונאטים (פונים זה לזה, בלי הצטלבות לידרים)
             (cdt:log "[L63] circle-spiral")
             (if *cdt-bars-ok*
               (progn
                 (setq sp-vals (cdt:spiral-dialog))
                 (if sp-vals
                   (progn
                     (setq sp-type (nth 0 sp-vals)   ; סוג / קוטר / פסיעה (בלי כמות)
                           sp-diam (nth 1 sp-vals)
                           sp-spac (nth 2 sp-vals)
                           ;; שדות BARS: f1=קידומת "ספירלה" (אותיות הפוכות בגלל RTL),
                           ;; f2=כמות כבויה, f3=סוג, f4=קוטר, f5=@, f6=פסיעה, השאר כבוי
                           sp-fields (list "הלריפס" "0" sp-type sp-diam
                                           (if (and sp-spac (not (equal sp-spac ""))
                                                    (not (equal sp-spac "0"))) "1" "0")
                                           (if sp-spac sp-spac "0")
                                           "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0")
                           ;; נקודת מגע שמאל-מעלה — מעל מפגש קו-הציר עם המעגל הפנימי (לא מבלבל)
                           sp-touch (polar cir-cen (* 0.8 pi) cir-ir)
                           ;; מראה של נקודת חיבור בלוק הדונאטים סביב ציר ה-X, מורמת מעט למעלה
                           sp-conn  (list (- (* 2.0 (car cir-cen)) (car bar-conn-pt))
                                          (+ (cadr bar-conn-pt) (* 3.0 sp-th))))
                     (cdt:draw-spiral-block sp-touch sp-conn -1 sp-fields
                       (cdt:get cfg "leader-layer") (cdt:get cfg "leader-color")
                       (cdt:get cfg "donut-txt-style") sp-th (cdt:get cfg "donut-txt-color"))))))

             ;; עוגנים — בלוק המוטות מימין: פורק משני הדונאטים הימניים (עליון+תחתון)
             (setq bar-d1 (car (cdt:closest-and-farthest-donut placed
                                 (list (caddr c-bb) (cadddr c-bb))))   ; ימין-עליון
                   bar-d2 (car (cdt:closest-and-farthest-donut placed
                                 (list (caddr c-bb) (cadr c-bb))))     ; ימין-תחתון
                   top-y  (+ ch-maxy 10.0)
                   cx     (car cir-cen))))

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
             (if (and (cdt:get cfg "dim-style")
                      (not (equal (cdt:get cfg "dim-style") "")))
               (if (tblsearch "DIMSTYLE" (cdt:get cfg "dim-style"))
                 (command "_.DIMSTYLE" "R" (cdt:get cfg "dim-style") "")
                 (princ (strcat "\nWarning: dim-style '" (cdt:get cfg "dim-style") "' not found."))))
             ;; אחרי שחזור הסגנון — קנה המידה מההגדרות גובר (אחרת הסגנון דורס אותו)
             (setvar "DIMSCALE" (atof (cdt:get cfg "dim-scale")))
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

             ;; BARS — דיאלוג חישוקים פעם אחת (2 אוגנים), ואז תווית לכל אחד
             (setq ls-stir-vals (cdt:stirrup-dialog-safe ls-sbb1))
             (cdt:draw-stirrup-label-safe ls-sbb1 ls-stir-vals
               (cdt:get cfg "stirrup-layer")
               (cdt:get cfg "stirrup-style")
               (atof (cdt:get cfg "stirrup-height"))
               (cdt:get cfg "stirrup-txt-color"))

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

             ;; BARS — תווית אוגן 2 (אותם ערכים, L= מחושב מחדש)
             (cdt:draw-stirrup-label-safe ls-sbb2 ls-stir-vals
               (cdt:get cfg "stirrup-layer")
               (cdt:get cfg "stirrup-style")
               (atof (cdt:get cfg "stirrup-height"))
               (cdt:get cfg "stirrup-txt-color"))

             ;; placed ו-conn-pt לבלוק מוטות — תחתית-ממורכז, מתחת לקו מידת הרוחב
             ;; זוג הדונאטים התחתונים (שמאל+ימין) → לידרים יורדים סימטרית למרכז
             (setq placed        ls-placed
                   bar-conn-pt   (cdt:bar-block-conn-pt ls-overall cfg)
                   bar-d1        (car (cdt:closest-and-farthest-donut ls-placed
                                        (list (car  ls-overall) (cadr ls-overall))))
                   bar-d2        (car (cdt:closest-and-farthest-donut ls-placed
                                        (list (caddr ls-overall) (cadr ls-overall)))))

             ;; top-y ו-cx לכותרת
             (setq top-y (cadddr ls-overall)
                   cx    (* 0.5 (+ (car ls-overall) (caddr ls-overall))))))

         ;; ─── מסלול צורת ח (U) — שלב ביניים: חיצוני + מלבנים פנימיים בלבד ───
         (if (= shape "chet")
           (progn
             (cdt:log "[L40] chet-path")
             (setq verts  (cdt:get-poly-verts ename)
                   ch-dec (cdt:chet-decompose verts offset))
             (if (null ch-dec)
               (progn (setvar "OSMODE" prev-osmode)
                      (princ "\nError: selected shape is not a valid U (chet).") (exit)))
             (setq ch-bb    (car  ch-dec)
                   ch-rects (cadr ch-dec)
                   ch-mark  (entlast))   ; סמן לפני ציור — למדידת גבול אמיתי אחר כך
             ;; גיאומטריה חיצונית — העתק הפוליגון
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "ext-color")))
             (command "_.COPY" (ssadd ename (ssadd)) "" '(0 0 0) '(0 0 0))
             (cdt:set-layer (entlast) (cdt:get cfg "ext-layer"))
             (setvar "CECOLOR" "256")

             ;; ── קווי מידה — 3 צדדים (לא הגב)
             (cdt:log "[L40b] chet-dims")
             (setq prev-dimscale (getvar "DIMSCALE")
                   dim-prev-lay  (getvar "CLAYER"))
             (cdt:ensure-layer (cdt:get cfg "dim-layer"))
             (setvar "CLAYER"   (cdt:get cfg "dim-layer"))
             (setvar "CECOLOR"  (cdt:color-str (cdt:get cfg "dim-color")))
             (if (and (cdt:get cfg "dim-style")
                      (not (equal (cdt:get cfg "dim-style") "")))
               (if (tblsearch "DIMSTYLE" (cdt:get cfg "dim-style"))
                 (command "_.DIMSTYLE" "R" (cdt:get cfg "dim-style") "")
                 (princ (strcat "\nWarning: dim-style '" (cdt:get cfg "dim-style") "' not found."))))
             ;; אחרי שחזור הסגנון — קנה המידה מההגדרות גובר (אחרת הסגנון דורס אותו)
             (setvar "DIMSCALE" (atof (cdt:get cfg "dim-scale")))
             (cdt:chet-dimensions ch-rects ch-bb CDT:DIM-OFFSET)
             (setvar "CLAYER"   dim-prev-lay)
             (setvar "CECOLOR"  "256")
             (setvar "DIMSCALE" prev-dimscale)

             ;; גיאומטריות פנימיות — כל מלבן מוקטן באופסט
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "int-color")))
             (foreach rc ch-rects
               (cdt:draw-closed-rect (cdt:bbox-inset rc offset) (cdt:get cfg "int-layer")))
             (setvar "CECOLOR" "256")

             ;; ── דונאטים ── מלבנים פנימיים מוקטנים
             (cdt:log "[L41] chet-donuts")
             (setq ch-beam (cdt:bbox-inset (nth 0 ch-rects) offset)
                   ch-lA   (cdt:bbox-inset (nth 1 ch-rects) offset)
                   ch-lB   (cdt:bbox-inset (nth 2 ch-rects) offset)
                   ch-bcen (cdt:bbox-center ch-beam)
                   ch-ov1  (cdt:bbox-intersect ch-beam ch-lA)
                   ch-ov2  (cdt:bbox-intersect ch-beam ch-lB)
                   placed  nil)
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "donut-color")))
             ;; 1) 8 פינות שני ריבועי החפיפה
             (setq placed (cdt:place-corner-donuts-tracked ch-ov1 donut-size donut-layer placed)
                   placed (cdt:place-corner-donuts-tracked ch-ov2 donut-size donut-layer placed))
             ;; 2+3) פינות קצה + מילוי צלעות לכל רגל; אוסף עוגנים לחיבור הקורה
             (setq ch-r1 (cdt:chet-leg-donuts ch-lA ch-ov1 ch-bcen donut-size donut-layer placed)
                   placed  (nth 0 ch-r1) ch-aof (nth 1 ch-r1) ch-arx (nth 2 ch-r1) ch-aif (nth 3 ch-r1))
             (setq ch-r2 (cdt:chet-leg-donuts ch-lB ch-ov2 ch-bcen donut-size donut-layer placed)
                   placed  (nth 0 ch-r2) ch-bof (nth 1 ch-r2) ch-brx (nth 2 ch-r2) ch-bif (nth 3 ch-r2))
             ;; הצלע החיצונית הרחוקה של הקורה (קצה רחוק -> פנים -> פנים -> קצה רחוק)
             (setq placed (cdt:fill-pts ch-aof ch-aif donut-size donut-layer placed)
                   placed (cdt:fill-pts ch-aif ch-bif donut-size donut-layer placed)
                   placed (cdt:fill-pts ch-bif ch-bof donut-size donut-layer placed))
             ;; תקרת המגרעת (בין שתי פינות הקעורות)
             (setq placed (cdt:fill-pts ch-arx ch-brx donut-size donut-layer placed))
             (setvar "CECOLOR" "256")
             (cdt:log (strcat "[L42] chet-donuts-done placed=" (itoa (length placed))))

             ;; ── גבול אמיתי של מה שצויר (גיאומטריה + מידות + דונאטים)
             (setq ch-ext  (cdt:ents-bbox-max ch-mark)
                   ch-maxx (car  ch-ext)
                   ch-maxy (cadr ch-ext))
             (if (null ch-maxx) (setq ch-maxx (caddr  ch-bb)))
             (if (null ch-maxy) (setq ch-maxy (cadddr ch-bb)))

             ;; ── חישוקים — 3 מלבנים בפריסת ח' (כמו בחתך), מימין ורחוק מהמידות
             (cdt:log "[L43] chet-stirrups")
             (setq ch-sgap 30.0
                   ch-sdx  (- (+ ch-maxx ch-sgap) (car ch-bb)))
             ;; BARS — דיאלוג חישוקים פעם אחת (3 מלבנים), ואז תווית לכל אחד
             (setq ch-stir-vals (cdt:stirrup-dialog-safe ch-beam))
             (foreach srect (list ch-beam ch-lA ch-lB)
               (setq ch-sbb (list (+ (car   srect) ch-sdx) (cadr   srect)
                                  (+ (caddr srect) ch-sdx) (cadddr srect)))
               (cdt:draw-stirrup-rect ch-sbb (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-color")
                 (cdt:get cfg "stirrup-txt-color"))
               (cdt:draw-stirrup-label-safe ch-sbb ch-stir-vals
                 (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-txt-color")))
             (cdt:log "[L44] after chet-stirrups")

             ;; חיבור לבלוק מוטות — אלכסון ימין-מטה מהפינה הימנית-תחתונה (זוג הדונאטים הקיצוניים התחתונים)
             (setq bar-conn-pt (cdt:bar-block-conn-pt ch-bb cfg)
                   bar-d1      (car (cdt:closest-and-farthest-donut placed
                                      (list (car  ch-bb) (cadr ch-bb))))
                   bar-d2      (car (cdt:closest-and-farthest-donut placed
                                      (list (caddr ch-bb) (cadr ch-bb))))
                   top-y       (+ ch-maxy 10.0)    ; כותרת מעל הגבול האמיתי (כולל המידות)
                   cx          (* 0.5 (+ (car ch-bb) (caddr ch-bb))))))

         ;; ─── מסלול זי (Z) — מבנה זהה ל-ח': גוף + 2 כנפיים, 2 אזורי חפיפה
         (if (= shape "zshape")
           (progn
             (cdt:log "[L50] zshape-path")
             (setq verts  (cdt:get-poly-verts ename)
                   ch-dec (cdt:zshape-decompose verts))
             (if (null ch-dec)
               (progn (setvar "OSMODE" prev-osmode)
                      (princ "\nError: selected shape is not a valid Z.") (exit)))
             (setq ch-bb    (car  ch-dec)
                   ch-rects (cadr ch-dec)
                   ch-mark  (entlast))   ; סמן לפני ציור — למדידת גבול אמיתי אחר כך
             ;; גיאומטריה חיצונית — העתק הפוליגון
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "ext-color")))
             (command "_.COPY" (ssadd ename (ssadd)) "" '(0 0 0) '(0 0 0))
             (cdt:set-layer (entlast) (cdt:get cfg "ext-layer"))
             (setvar "CECOLOR" "256")

             ;; ── קווי מידה
             (cdt:log "[L50b] zshape-dims")
             (setq prev-dimscale (getvar "DIMSCALE")
                   dim-prev-lay  (getvar "CLAYER"))
             (cdt:ensure-layer (cdt:get cfg "dim-layer"))
             (setvar "CLAYER"   (cdt:get cfg "dim-layer"))
             (setvar "CECOLOR"  (cdt:color-str (cdt:get cfg "dim-color")))
             (if (and (cdt:get cfg "dim-style")
                      (not (equal (cdt:get cfg "dim-style") "")))
               (if (tblsearch "DIMSTYLE" (cdt:get cfg "dim-style"))
                 (command "_.DIMSTYLE" "R" (cdt:get cfg "dim-style") "")
                 (princ (strcat "\nWarning: dim-style '" (cdt:get cfg "dim-style") "' not found."))))
             ;; אחרי שחזור הסגנון — קנה המידה מההגדרות גובר (אחרת הסגנון דורס אותו)
             (setvar "DIMSCALE" (atof (cdt:get cfg "dim-scale")))
             (cdt:zshape-dimensions ch-rects ch-bb CDT:DIM-OFFSET)
             (setvar "CLAYER"   dim-prev-lay)
             (setvar "CECOLOR"  "256")
             (setvar "DIMSCALE" prev-dimscale)

             ;; גיאומטריות פנימיות — כל מלבן מוקטן באופסט
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "int-color")))
             (foreach rc ch-rects
               (cdt:draw-closed-rect (cdt:bbox-inset rc offset) (cdt:get cfg "int-layer")))
             (setvar "CECOLOR" "256")

             ;; ── דונאטים ── מלבנים פנימיים מוקטנים
             (cdt:log "[L51] zshape-donuts")
             (setq ch-beam (cdt:bbox-inset (nth 0 ch-rects) offset)   ; גוף
                   ch-lA   (cdt:bbox-inset (nth 1 ch-rects) offset)   ; כנף A
                   ch-lB   (cdt:bbox-inset (nth 2 ch-rects) offset)   ; כנף B
                   ch-bcen (cdt:bbox-center ch-beam)
                   ch-ov1  (cdt:bbox-intersect ch-beam ch-lA)
                   ch-ov2  (cdt:bbox-intersect ch-beam ch-lB)
                   placed  nil)
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "donut-color")))
             ;; 1) 8 פינות שני אזורי החפיפה
             (setq placed (cdt:place-corner-donuts-tracked ch-ov1 donut-size donut-layer placed)
                   placed (cdt:place-corner-donuts-tracked ch-ov2 donut-size donut-layer placed))
             ;; 2+3) פינות קצה + מילוי צלעות לכל כנף; אוסף עוגנים לחיבור הגוף
             (setq ch-r1 (cdt:chet-leg-donuts ch-lA ch-ov1 ch-bcen donut-size donut-layer placed)
                   placed  (nth 0 ch-r1) ch-aof (nth 1 ch-r1) ch-arx (nth 2 ch-r1) ch-aif (nth 3 ch-r1))
             (setq ch-r2 (cdt:chet-leg-donuts ch-lB ch-ov2 ch-bcen donut-size donut-layer placed)
                   placed  (nth 0 ch-r2) ch-bof (nth 1 ch-r2) ch-brx (nth 2 ch-r2) ch-bif (nth 3 ch-r2))
             ;; שתי פאות הגוף — מילוי על אותו טווח בדיוק (בין שני אזורי החפיפה),
             ;; כך ששתי הצלעות מקבלות אותם מיקומים → דונאטים מקבילים כמו שלבי סולם.
             ;; (ch-aof/ch-arx משמשים כאן כגבולות הטווח; הערכים שהוחזרו מהכנפיים אינם נחוצים יותר.)
             ;; ch-bof = הסטה פנימה (donut-inset) — אותו פער דונאט-קו כמו כל שאר הדונאטים
             (setq ch-bof (cdt:donut-inset donut-size ch-beam))
             (if (> (cdt:bbox-height ch-beam) (cdt:bbox-width ch-beam))
               ;; גוף אנכי → פאות שמאל/ימין, מוסטות פנימה, טווח משותף לאורך y
               (progn
                 (if (> (cadr ch-ov1) (cadr ch-ov2))
                   (setq ch-aof (cadddr ch-ov2) ch-arx (cadr ch-ov1))   ; ראש חפיפה תחתונה → תחתית עליונה
                   (setq ch-aof (cadddr ch-ov1) ch-arx (cadr ch-ov2)))
                 (setq placed (cdt:fill-pts (list (+ (car   ch-beam) ch-bof) ch-aof)
                                            (list (+ (car   ch-beam) ch-bof) ch-arx)
                                            donut-size donut-layer placed)
                       placed (cdt:fill-pts (list (- (caddr ch-beam) ch-bof) ch-aof)
                                            (list (- (caddr ch-beam) ch-bof) ch-arx)
                                            donut-size donut-layer placed)))
               ;; גוף אופקי → פאות עליונה/תחתונה, מוסטות פנימה, טווח משותף לאורך x
               (progn
                 (if (> (car ch-ov1) (car ch-ov2))
                   (setq ch-aof (caddr ch-ov2) ch-arx (car ch-ov1))     ; ימין חפיפה שמאלית → שמאל ימנית
                   (setq ch-aof (caddr ch-ov1) ch-arx (car ch-ov2)))
                 (setq placed (cdt:fill-pts (list ch-aof (+ (cadr   ch-beam) ch-bof))
                                            (list ch-arx (+ (cadr   ch-beam) ch-bof))
                                            donut-size donut-layer placed)
                       placed (cdt:fill-pts (list ch-aof (- (cadddr ch-beam) ch-bof))
                                            (list ch-arx (- (cadddr ch-beam) ch-bof))
                                            donut-size donut-layer placed))))
             (setvar "CECOLOR" "256")
             (cdt:log (strcat "[L52] zshape-donuts-done placed=" (itoa (length placed))))

             ;; ── גבול אמיתי של מה שצויר
             (setq ch-ext  (cdt:ents-bbox-max ch-mark)
                   ch-maxx (car  ch-ext)
                   ch-maxy (cadr ch-ext))
             (if (null ch-maxx) (setq ch-maxx (caddr  ch-bb)))
             (if (null ch-maxy) (setq ch-maxy (cadddr ch-bb)))

             ;; ── חישוקים — 3 מלבנים בפריסת זי, מימין ורחוק מהמידות
             (cdt:log "[L53] zshape-stirrups")
             (setq ch-sgap 30.0
                   ch-sdx  (- (+ ch-maxx ch-sgap) (car ch-bb)))
             ;; BARS — דיאלוג חישוקים פעם אחת (3 מלבנים), ואז תווית לכל אחד
             (setq ch-stir-vals (cdt:stirrup-dialog-safe ch-beam))
             (foreach srect (list ch-beam ch-lA ch-lB)
               (setq ch-sbb (list (+ (car   srect) ch-sdx) (cadr   srect)
                                  (+ (caddr srect) ch-sdx) (cadddr srect)))
               (cdt:draw-stirrup-rect ch-sbb (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-color")
                 (cdt:get cfg "stirrup-txt-color"))
               (cdt:draw-stirrup-label-safe ch-sbb ch-stir-vals
                 (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-txt-color")))
             (cdt:log "[L54] after zshape-stirrups")

             ;; חיבור לבלוק מוטות — אלכסון ימין-מטה מהפינה הימנית-תחתונה
             (setq bar-conn-pt (cdt:bar-block-conn-pt ch-bb cfg)
                   bar-d1      (car (cdt:closest-and-farthest-donut placed
                                      (list (car  ch-bb) (cadr ch-bb))))
                   bar-d2      (car (cdt:closest-and-farthest-donut placed
                                      (list (caddr ch-bb) (cadr ch-bb))))
                   top-y       (+ ch-maxy 10.0)
                   cx          (* 0.5 (+ (car ch-bb) (caddr ch-bb))))))

         ;; ─── מסלול ט (T) — כנף ברוחב מלא + רגל אחת ממורכזת ──
         (if (= shape "tshape")
           (progn
             (cdt:log "[L60] tshape-path")
             (setq verts  (cdt:get-poly-verts ename)
                   ch-dec (cdt:tshape-decompose verts))
             (if (null ch-dec)
               (progn (setvar "OSMODE" prev-osmode)
                      (princ "\nError: selected shape is not a valid T.") (exit)))
             (setq ch-bb    (car  ch-dec)
                   ch-rects (cadr ch-dec)
                   ch-beam  (nth 0 ch-rects)   ; כנף
                   ch-lA    (nth 1 ch-rects)   ; רגל
                   ch-mark  (entlast))   ; סמן לפני ציור — למדידת גבול אמיתי אחר כך
             ;; גיאומטריה חיצונית — העתק הפוליגון
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "ext-color")))
             (command "_.COPY" (ssadd ename (ssadd)) "" '(0 0 0) '(0 0 0))
             (cdt:set-layer (entlast) (cdt:get cfg "ext-layer"))
             (setvar "CECOLOR" "256")

             ;; ── קווי מידה — 3 מקטעים בצד הפתוח + אורך הרגל (כמו ח')
             (cdt:log "[L60b] tshape-dims")
             (setq prev-dimscale (getvar "DIMSCALE")
                   dim-prev-lay  (getvar "CLAYER"))
             (cdt:ensure-layer (cdt:get cfg "dim-layer"))
             (setvar "CLAYER"   (cdt:get cfg "dim-layer"))
             (setvar "CECOLOR"  (cdt:color-str (cdt:get cfg "dim-color")))
             (if (and (cdt:get cfg "dim-style")
                      (not (equal (cdt:get cfg "dim-style") "")))
               (if (tblsearch "DIMSTYLE" (cdt:get cfg "dim-style"))
                 (command "_.DIMSTYLE" "R" (cdt:get cfg "dim-style") "")
                 (princ (strcat "\nWarning: dim-style '" (cdt:get cfg "dim-style") "' not found."))))
             (setvar "DIMSCALE" (atof (cdt:get cfg "dim-scale")))
             (cdt:tshape-dimensions ch-rects ch-bb CDT:DIM-OFFSET)
             (setvar "CLAYER"   dim-prev-lay)
             (setvar "CECOLOR"  "256")
             (setvar "DIMSCALE" prev-dimscale)

             ;; ── גיאומטריה פנימית — 2 מלבנים חופפים (כנף + רגל מוארכת דרך הכנף), כמו ר'/ח' ──
             (cdt:log "[L61] tshape-inner")
             ;; רגל "מוארכת" — נמתחת לכל הממד הניצב, חודרת לתוך הכנף (בדיוק כמו legA/legB בח')
             (setq t-horiz (< (abs (- (cdt:bbox-width ch-beam) (cdt:bbox-width ch-bb))) CDT:TOL))
             (setq t-stem-full
               (if t-horiz
                 (list (car ch-lA) (cadr ch-bb) (caddr ch-lA) (cadddr ch-bb))     ; לכל הגובה
                 (list (car ch-bb) (cadr ch-lA) (caddr ch-bb) (cadddr ch-lA))))   ; לכל הרוחב
             (setq t-flange-in (cdt:bbox-inset ch-beam     offset)
                   t-stem-in   (cdt:bbox-inset t-stem-full offset))
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "int-color")))
             (cdt:draw-closed-rect t-flange-in (cdt:get cfg "int-layer"))
             (cdt:draw-closed-rect t-stem-in   (cdt:get cfg "int-layer"))
             (setvar "CECOLOR" "256")

             ;; ── דונאטים — 4 אזורים: חפיפה, 2 אוזני הכנף, השלמת הרגל (כמו ר': חפיפה+2 זרועות) ──
             (cdt:log "[L62] tshape-donuts")
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "donut-color")))
             (cdt:log (strcat "[L62a] flange-in=" (vl-princ-to-string t-flange-in)
                              " stem-in=" (vl-princ-to-string t-stem-in)
                              " horiz=" (if t-horiz "T" "nil")))
             (setq t-ov       (cdt:bbox-intersect t-flange-in t-stem-in)
                   placed     (cdt:place-corner-donuts-tracked t-ov donut-size donut-layer nil)
                   t-ov-inset (cdt:donut-inset donut-size t-ov)
                   t-ov-cen   (cdt:bbox-center t-ov)
                   t-ov-bl (cdt:corner-toward-center (list (car   t-ov) (cadr   t-ov)) t-ov-cen t-ov-inset)
                   t-ov-br (cdt:corner-toward-center (list (caddr t-ov) (cadr   t-ov)) t-ov-cen t-ov-inset)
                   t-ov-tr (cdt:corner-toward-center (list (caddr t-ov) (cadddr t-ov)) t-ov-cen t-ov-inset)
                   t-ov-tl (cdt:corner-toward-center (list (car   t-ov) (cadddr t-ov)) t-ov-cen t-ov-inset))
             (if t-horiz
               (progn
                 ;; אוזן שמאל — חלק הכנף שמשמאל לחפיפה
                 (setq t-e1 (list (car t-flange-in) (cadr t-ov) (car t-ov) (cadddr t-ov))
                       t-e1-inset (cdt:donut-inset donut-size t-e1)
                       t-e1-cen   (cdt:bbox-center t-e1)
                       t-e1-p1 (cdt:corner-toward-center (list (car t-e1) (cadr   t-e1)) t-e1-cen t-e1-inset)
                       t-e1-p2 (cdt:corner-toward-center (list (car t-e1) (cadddr t-e1)) t-e1-cen t-e1-inset)
                       placed (cdt:donut-if-new t-e1-p1 donut-size donut-layer placed)
                       placed (cdt:donut-if-new t-e1-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-ov-bl t-e1-p1 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-ov-tl t-e1-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-e1-p1 t-e1-p2 donut-size donut-layer placed))
                 ;; אוזן ימין — חלק הכנף שמימין לחפיפה
                 (setq t-e2 (list (caddr t-ov) (cadr t-ov) (caddr t-flange-in) (cadddr t-ov))
                       t-e2-inset (cdt:donut-inset donut-size t-e2)
                       t-e2-cen   (cdt:bbox-center t-e2)
                       t-e2-p1 (cdt:corner-toward-center (list (caddr t-e2) (cadr   t-e2)) t-e2-cen t-e2-inset)
                       t-e2-p2 (cdt:corner-toward-center (list (caddr t-e2) (cadddr t-e2)) t-e2-cen t-e2-inset)
                       placed (cdt:donut-if-new t-e2-p1 donut-size donut-layer placed)
                       placed (cdt:donut-if-new t-e2-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-ov-br t-e2-p1 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-ov-tr t-e2-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-e2-p1 t-e2-p2 donut-size donut-layer placed))
                 ;; השלמת הרגל — הקצה החופשי (מעבר לחפיפה, למעלה או למטה)
                 (if (< (cadr t-stem-in) (cadr t-ov))
                   (setq t-ext (list (car t-stem-in) (cadr t-stem-in) (caddr t-stem-in) (cadr t-ov))
                         t-anch1 t-ov-bl  t-anch2 t-ov-br)
                   (setq t-ext (list (car t-stem-in) (cadddr t-ov) (caddr t-stem-in) (cadddr t-stem-in))
                         t-anch1 t-ov-tl  t-anch2 t-ov-tr))
                 (setq t-ext-inset (cdt:donut-inset donut-size t-ext)
                       t-ext-cen   (cdt:bbox-center t-ext))
                 (if (< (cadr t-stem-in) (cadr t-ov))
                   (setq t-ext-p1 (cdt:corner-toward-center (list (car   t-ext) (cadr t-ext)) t-ext-cen t-ext-inset)
                         t-ext-p2 (cdt:corner-toward-center (list (caddr t-ext) (cadr t-ext)) t-ext-cen t-ext-inset))
                   (setq t-ext-p1 (cdt:corner-toward-center (list (car   t-ext) (cadddr t-ext)) t-ext-cen t-ext-inset)
                         t-ext-p2 (cdt:corner-toward-center (list (caddr t-ext) (cadddr t-ext)) t-ext-cen t-ext-inset)))
                 (setq placed (cdt:donut-if-new t-ext-p1 donut-size donut-layer placed)
                       placed (cdt:donut-if-new t-ext-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-anch1 t-ext-p1 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-anch2 t-ext-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-ext-p1 t-ext-p2 donut-size donut-layer placed)))
               (progn
                 ;; אוזן תחתונה — חלק הכנף שמתחת לחפיפה
                 (setq t-e1 (list (car t-flange-in) (cadr t-flange-in) (caddr t-flange-in) (cadr t-ov))
                       t-e1-inset (cdt:donut-inset donut-size t-e1)
                       t-e1-cen   (cdt:bbox-center t-e1)
                       t-e1-p1 (cdt:corner-toward-center (list (car   t-e1) (cadr t-e1)) t-e1-cen t-e1-inset)
                       t-e1-p2 (cdt:corner-toward-center (list (caddr t-e1) (cadr t-e1)) t-e1-cen t-e1-inset)
                       placed (cdt:donut-if-new t-e1-p1 donut-size donut-layer placed)
                       placed (cdt:donut-if-new t-e1-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-ov-bl t-e1-p1 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-ov-br t-e1-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-e1-p1 t-e1-p2 donut-size donut-layer placed))
                 ;; אוזן עליונה — חלק הכנף שמעל לחפיפה
                 (setq t-e2 (list (car t-flange-in) (cadddr t-ov) (caddr t-flange-in) (cadddr t-flange-in))
                       t-e2-inset (cdt:donut-inset donut-size t-e2)
                       t-e2-cen   (cdt:bbox-center t-e2)
                       t-e2-p1 (cdt:corner-toward-center (list (car   t-e2) (cadddr t-e2)) t-e2-cen t-e2-inset)
                       t-e2-p2 (cdt:corner-toward-center (list (caddr t-e2) (cadddr t-e2)) t-e2-cen t-e2-inset)
                       placed (cdt:donut-if-new t-e2-p1 donut-size donut-layer placed)
                       placed (cdt:donut-if-new t-e2-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-ov-tl t-e2-p1 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-ov-tr t-e2-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-e2-p1 t-e2-p2 donut-size donut-layer placed))
                 ;; השלמת הרגל — הקצה החופשי (מעבר לחפיפה, שמאלה או ימינה)
                 (if (< (car t-stem-in) (car t-ov))
                   (setq t-ext (list (car t-stem-in) (cadr t-stem-in) (car t-ov) (cadddr t-stem-in))
                         t-anch1 t-ov-bl  t-anch2 t-ov-tl)
                   (setq t-ext (list (caddr t-ov) (cadr t-stem-in) (caddr t-stem-in) (cadddr t-stem-in))
                         t-anch1 t-ov-br  t-anch2 t-ov-tr))
                 (setq t-ext-inset (cdt:donut-inset donut-size t-ext)
                       t-ext-cen   (cdt:bbox-center t-ext))
                 (if (< (car t-stem-in) (car t-ov))
                   (setq t-ext-p1 (cdt:corner-toward-center (list (car t-ext) (cadr   t-ext)) t-ext-cen t-ext-inset)
                         t-ext-p2 (cdt:corner-toward-center (list (car t-ext) (cadddr t-ext)) t-ext-cen t-ext-inset))
                   (setq t-ext-p1 (cdt:corner-toward-center (list (caddr t-ext) (cadr   t-ext)) t-ext-cen t-ext-inset)
                         t-ext-p2 (cdt:corner-toward-center (list (caddr t-ext) (cadddr t-ext)) t-ext-cen t-ext-inset)))
                 (setq placed (cdt:donut-if-new t-ext-p1 donut-size donut-layer placed)
                       placed (cdt:donut-if-new t-ext-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-anch1 t-ext-p1 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-anch2 t-ext-p2 donut-size donut-layer placed)
                       placed (cdt:fill-pts t-ext-p1 t-ext-p2 donut-size donut-layer placed))))
             (setvar "CECOLOR" "256")
             (cdt:log (strcat "[L63] tshape-donuts-done placed=" (itoa (length placed))))

             ;; ── גבול אמיתי של מה שצויר (גיאומטריה + מידות + דונאטים)
             (setq ch-ext  (cdt:ents-bbox-max ch-mark)
                   ch-maxx (car  ch-ext)
                   ch-maxy (cadr ch-ext))
             (if (null ch-maxx) (setq ch-maxx (caddr  ch-bb)))
             (if (null ch-maxy) (setq ch-maxy (cadddr ch-bb)))

             ;; ── חישוקים — 2 מלבנים (כנף+רגל), לפי המידות הפנימיות (קו הכיסוי) כמו בכל שאר הצורות
             (cdt:log "[L64] tshape-stirrups")
             (setq ch-sgap 30.0
                   ch-sdx  (- (+ ch-maxx ch-sgap) (car ch-bb))
                   ch-lA   (cdt:bbox-inset ch-lA offset))   ; הרגל האמיתית (לא המוארכת) — מוקטנת כמו הכנף
             ;; BARS — דיאלוג חישוקים פעם אחת (2 מלבנים), ואז תווית לכל אחד
             (setq ch-stir-vals (cdt:stirrup-dialog-safe t-flange-in))
             (foreach srect (list t-flange-in ch-lA)
               (setq ch-sbb (list (+ (car   srect) ch-sdx) (cadr   srect)
                                  (+ (caddr srect) ch-sdx) (cadddr srect)))
               (cdt:draw-stirrup-rect ch-sbb (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-color")
                 (cdt:get cfg "stirrup-txt-color"))
               (cdt:draw-stirrup-label-safe ch-sbb ch-stir-vals
                 (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-txt-color")))
             (cdt:log "[L65] after tshape-stirrups")

             ;; חיבור לבלוק מוטות — אלכסון ימין-מטה מהפינה הימנית-תחתונה
             (setq bar-conn-pt (cdt:bar-block-conn-pt ch-bb cfg)
                   bar-d1      (car (cdt:closest-and-farthest-donut placed
                                      (list (car  ch-bb) (cadr ch-bb))))
                   bar-d2      (car (cdt:closest-and-farthest-donut placed
                                      (list (caddr ch-bb) (cadr ch-bb))))
                   top-y       (+ ch-maxy 10.0)
                   cx          (* 0.5 (+ (car ch-bb) (caddr ch-bb))))))

         ;; ─── מסלול "קוסטום" — עמוד מורכב לפי מלבנים שהמשתמש מסמן ──
         (if (= shape "custom")
           (progn
             (cdt:log "[L70] custom-path")
             (setq cu-mark (entlast))   ; סמן לפני כל ציור — למדידת גבול אמיתי

             ;; ── לולאת סימון מלבנים — מדליק את כל הצמדות ה-OSNAP לנוחות הצבעה
             ;; (15359 = כל התיבות מסומנות: קצה/אמצע/מרכז/צומת/רבע/חיתוך/הארכה/
             ;;  הכנסה/ניצב/משיק/קרוב/חיתוך-מדומה/מקביל). בסוף הפקודה משוחזר prev-osmode.
             (setvar "OSMODE" 15359)
             (setq cu-rects nil  cu-more T)
             (while cu-more
               (setq cu-p1 (getpoint "\nMark rectangle - first corner (Enter to finish): "))
               (if (null cu-p1)
                 (setq cu-more nil)
                 (progn
                   (setq cu-p2 (getcorner cu-p1 "\nOpposite corner: "))
                   (if (null cu-p2)
                     (setq cu-more nil)
                     (progn
                       (setq cu-rects (cons (cdt:bbox-from-verts (list cu-p1 cu-p2)) cu-rects))
                       (initget "Yes No")
                       (setq cu-ans (getkword "\nAnother rectangle? [Yes/No] <Yes>: "))
                       (if (= cu-ans "No") (setq cu-more nil)))))))
             (setvar "OSMODE" 0)
             (setq cu-rects (reverse cu-rects))

             (if (null cu-rects)
               (progn (setvar "OSMODE" prev-osmode)
                      (princ "\nNo rectangles marked - aborting.") (exit)))

             ;; ── מתאר האיחוד + תיבה תוחמת כוללת ──
             (setq cu-loops (mapcar 'cu:ccw (cu:trace-loops (cu:union-segs cu-rects)))
                   cu-bb    (cdt:bbox-from-verts
                              (apply 'append
                                (mapcar '(lambda (r)
                                           (list (list (car r)   (cadr r))
                                                 (list (caddr r) (cadddr r)))) cu-rects))))
             (cdt:log (strcat "[L71] custom loops=" (itoa (length cu-loops))))

             ;; ── גיאומטריה חיצונית = העתק מדויק של המתאר שנבחר ──
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "ext-color")))
             (command "_.COPY" (ssadd ename (ssadd)) "" '(0 0 0) '(0 0 0))
             (cdt:set-layer (entlast) (cdt:get cfg "ext-layer"))
             (setvar "CECOLOR" "256")

             ;; ── קווי מידה (לפי מתאר האיחוד, כולל נקודות חיתוך) ──
             (cdt:log "[L71b] custom-dims")
             (setq prev-dimscale (getvar "DIMSCALE")  dim-prev-lay (getvar "CLAYER"))
             (cdt:ensure-layer (cdt:get cfg "dim-layer"))
             (setvar "CLAYER"  (cdt:get cfg "dim-layer"))
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "dim-color")))
             (if (and (cdt:get cfg "dim-style") (not (equal (cdt:get cfg "dim-style") "")))
               (if (tblsearch "DIMSTYLE" (cdt:get cfg "dim-style"))
                 (command "_.DIMSTYLE" "R" (cdt:get cfg "dim-style") "")
                 (princ (strcat "\nWarning: dim-style '" (cdt:get cfg "dim-style") "' not found."))))
             (setvar "DIMSCALE" (atof (cdt:get cfg "dim-scale")))
             (cu:dimensions cu-rects cu-bb CDT:DIM-OFFSET)
             (setvar "CLAYER"  dim-prev-lay)
             (setvar "CECOLOR" "256")
             (setvar "DIMSCALE" prev-dimscale)

             ;; ── חישוקים בתוך הצורה — כל מלבן מוקטן באופסט, מצויר במקומו (התא בפועל) ──
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "int-color")))
             (foreach rc cu-rects
               (cdt:draw-closed-rect (cdt:bbox-inset rc offset) (cdt:get cfg "int-layer")))
             (setvar "CECOLOR" "256")

             ;; ── דונאטים — לכל תא, על צלעות חיצוניות בלבד (מיושר עם התאים, בלי כפילויות) ──
             (cdt:log "[L72] custom-donuts")
             (setvar "CECOLOR" (cdt:color-str (cdt:get cfg "donut-color")))
             (setq placed (cu:tie-donuts cu-rects donut-size offset donut-layer nil))
             (setvar "CECOLOR" "256")
             (cdt:log (strcat "[L73] custom-donuts-done placed=" (itoa (length placed))))

             ;; ── גבול אמיתי של מה שצויר (כולל מידות) ──
             (setq cu-ext  (cdt:ents-bbox-max cu-mark)
                   cu-maxx (car cu-ext)  cu-maxy (cadr cu-ext))
             (if (null cu-maxx) (setq cu-maxx (caddr  cu-bb)))
             (if (null cu-maxy) (setq cu-maxy (cadddr cu-bb)))

             ;; ── חישוקים סמליים — נפרד לכל מלבן, מסודרים בשורה אחד ליד השני ──
             ;; הדיאלוג נפתח פעם אחת בלבד; L= מחושב מחדש פר-מלבן בציור התווית
             (cdt:log "[L74] custom-stirrups")
             (setq cu-stir-vals
               (cdt:stirrup-dialog-safe (cdt:bbox-inset (car cu-rects) offset)))
             (setq cu-sx (+ cu-maxx 30.0))
             (foreach rc cu-rects
               (setq bb-int (cdt:bbox-inset rc offset)
                     cu-w   (cdt:bbox-width  bb-int)
                     cu-h   (cdt:bbox-height bb-int)
                     cu-sbb (list cu-sx (cadr cu-bb)
                                  (+ cu-sx cu-w) (+ (cadr cu-bb) cu-h)))
               (cdt:draw-stirrup-rect cu-sbb (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-color")
                 (cdt:get cfg "stirrup-txt-color"))
               (cdt:draw-stirrup-label-safe cu-sbb cu-stir-vals
                 (cdt:get cfg "stirrup-layer")
                 (cdt:get cfg "stirrup-style")
                 (atof (cdt:get cfg "stirrup-height"))
                 (cdt:get cfg "stirrup-txt-color"))
               (setq cu-sx (+ cu-sx cu-w 25.0)))

             ;; ── עוגנים לבלוק המוטות + כותרת ──
             (setq bar-conn-pt (cdt:bar-block-conn-pt cu-bb cfg)
                   bar-d1 (car (cdt:closest-and-farthest-donut placed
                                 (list (car  cu-bb) (cadr cu-bb))))
                   bar-d2 (car (cdt:closest-and-farthest-donut placed
                                 (list (caddr cu-bb) (cadr cu-bb))))
                   top-y  (+ cu-maxy 10.0)
                   cx     (* 0.5 (+ (car cu-bb) (caddr cu-bb))))))

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
                 (ch-bb       (list (car ch-bb)       (cadr ch-bb)))
                 (c-bb        (list (car c-bb)        (cadr c-bb)))
                 (cu-bb       (list (car cu-bb)       (cadr cu-bb)))
                 (t           '(0.0 0.0))))

             ;; יצירת הגדרת בלוק — מסיר אובייקטים ומגדיר בלוק
             (if (tblsearch "BLOCK" blk-name)
               (command "_.BLOCK" blk-name "Yes" blk-base blk-ss "")
               (command "_.BLOCK" blk-name blk-base blk-ss ""))

             ;; הנחת הבלוק — PAUSE: הבלוק עוקב אחרי הסמן עד לחיצה
             (princ "\nPlace block (pick insertion point): ")
             (command "_.INSERT" blk-name PAUSE 1 1 0)
             ;; פיצוץ אוטומטי — מחזיר לישויות בודדות (רק אם אכן נוצר בלוק)
             (setq ins-ent (entlast))
             (if (and ins-ent (= (cdr (assoc 0 (entget ins-ent))) "INSERT"))
               (command "_.EXPLODE" ins-ent))))

         ;; שחזור OSNAP
         (setvar "OSMODE" prev-osmode)

         (princ "\nCOLDET complete.")))))

  (princ))

;; חיבור לסרגל המשותף (toolbar hub). אם ה-hub לא טעון — מדלג בשקט.
(if tb:add-button (tb:add-button "COLDET" "^C^CCOLDET " "col"))

;;; ─── הודעת טעינה ─────────────────────────────────────────────
(princ "\nCOLDET 1.1 loaded. Run: COLDET\n")
(princ)
