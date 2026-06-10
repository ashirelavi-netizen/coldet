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

;;; ─── קבועים ─────────────────────────────────────────────────
(setq CDT:MAX-SPACING 18.0)   ; רווח מקסימלי בין דונאטים
(setq CDT:INSET        1.0)   ; מרחק דונאט מהגיאומטריה הפנימית
(setq CDT:LEAD-DIST   10.0)   ; מרחק נקודת חיבור ליידר
(setq CDT:HOOK-LEN    10.0)   ; אורך וו אוגן
(setq CDT:HOOK-EXT     3.0)   ; הרחבה ויזואלית של וו (הפרדה)

;;; ============================================================
;;; A. הגדרות — שמירה וטעינה
;;; ============================================================

(defun cdt:settings-path (/ ldir)
  (setq ldir (cdt:lsp-dir))
  (if (stringp ldir)
    (strcat ldir "\\coldet_settings.dat")
    (strcat (getenv "USERPROFILE") "\\coldet_settings.dat")))

(defun cdt:defaults ()
  (list
    (cons "version"       "1.1")
    (cons "ext-layer"     "0")
    (cons "int-layer"     "0")
    (cons "int-offset"    "3.0")
    (cons "donut-layer"   "0")
    (cons "donut-size"    "1.0")
    (cons "leader-text"   "")
    (cons "dim-layer"     "0")
    (cons "dim-style"     "Standard")
    (cons "dim-scale"     "50.0")
    (cons "title-layer"   "0")
    (cons "title-style1"  "Standard")
    (cons "title-height1" "5.0")
    (cons "title-style2"  "Standard")
    (cons "title-height2" "2.5")
    (cons "title-lweight" "25")
    (cons "stirrup-layer" "0")))

(defun cdt:save (cfg / f)
  (setq f (open (cdt:settings-path) "w"))
  (foreach p cfg
    (write-line (strcat (car p) "|" (cdr p)) f))
  (close f))

(defun cdt:load (/ path f line pos cfg)
  (setq path (cdt:settings-path))
  (if (findfile path)
    (progn
      (setq cfg nil  f (open path "r"))
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

(defun cdt:pick-layer (msg / ent)
  (princ (strcat "\n" msg ": "))
  (setq ent (car (entsel)))
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

(defun cdt:get-poly-verts (ename / ed verts)
  (setq ed (entget ename)  verts nil)
  (foreach pair ed
    (if (= (car pair) 10)
      (setq verts (append verts (list (cdr pair))))))
  verts)

(defun cdt:detect-shape (ename / etype verts n)
  (setq etype (cdr (assoc 0 (entget ename))))
  (cond
    ((= etype "CIRCLE")  "circle")
    ((or (= etype "LWPOLYLINE") (= etype "POLYLINE"))
     (setq verts (cdt:get-poly-verts ename)
           n     (length verts))
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

(defun cdt:draw-closed-rect (bb layer)
  (command "_.PLINE"
    (list (car bb)   (cadr bb))
    (list (caddr bb) (cadr bb))
    (list (caddr bb) (cadddr bb))
    (list (car bb)   (cadddr bb))
    "C")
  (cdt:set-layer (entlast) layer))

(defun cdt:draw-line (p1 p2 layer)
  (command "_.LINE" p1 p2 "")
  (cdt:set-layer (entlast) layer))

(defun cdt:draw-donut (center size layer)
  (command "_.DONUT" 0 size center "")
  (cdt:set-layer (entlast) layer))

(defun cdt:draw-text-center (pt height style txt layer angle)
  (command "_.TEXT" "J" "MC" pt height angle txt)
  (setq ename (entlast))
  (entmod (subst (cons 8 layer) (assoc 8 (entget ename)) (entget ename)))
  (if (assoc 7 (entget ename))
    (entmod (subst (cons 7 style) (assoc 7 (entget ename)) (entget ename))))
  ename)

;;; ============================================================
;;; H. דונאטים — מלבן
;;; ============================================================

(defun cdt:corner-toward-center (corner center inset / dx dy len)
  (setq dx  (- (car center)  (car corner))
        dy  (- (cadr center) (cadr corner))
        len (sqrt (+ (* dx dx) (* dy dy))))
  (if (> len 0.0001)
    (list (+ (car corner)  (* inset (/ dx len)))
          (+ (cadr corner) (* inset (/ dy len))))
    corner))

(defun cdt:place-corner-donuts (bb-int size layer / corners center ents)
  (setq corners (cdt:bbox-corners bb-int)
        center  (cdt:bbox-center  bb-int)
        ents    nil)
  (foreach c corners
    (setq ents (append ents
      (list (cdt:draw-donut
              (cdt:corner-toward-center c center CDT:INSET)
              size layer)))))
  ents)

(defun cdt:place-edge-donuts (bb-int size layer /
                               w h
                               bl br tr tl
                               center
                               avail-h avail-w
                               nh nw i tp ep pos ents)
  (setq corners (cdt:bbox-corners bb-int)
        bl (nth 0 corners)  br (nth 1 corners)
        tr (nth 2 corners)  tl (nth 3 corners)
        w  (cdt:bbox-width  bb-int)
        h  (cdt:bbox-height bb-int)
        center (cdt:bbox-center bb-int)
        ents nil)

  ; צלעות אנכיות (גובה h)
  (setq avail-h (- h (* 2.0 CDT:INSET))
        nh      (- (cdt:ceiling-int (/ avail-h CDT:MAX-SPACING)) 1))

  ; צלעות אופקיות (רוחב w)
  (setq avail-w (- w (* 2.0 CDT:INSET))
        nw      (- (cdt:ceiling-int (/ avail-w CDT:MAX-SPACING)) 1))

  ; צלע שמאל (BL → TL)
  (if (> nh 0)
    (progn (setq i 1)
      (while (<= i nh)
        (setq tp (/ (float i) (+ nh 1))
              ep (cdt:lerp (list (car bl) (+ (cadr bl) CDT:INSET))
                           (list (car tl) (- (cadr tl) CDT:INSET)) tp)
              pos (list (+ (car ep) CDT:INSET) (cadr ep)))
        (setq ents (append ents (list (cdt:draw-donut pos size layer))))
        (setq i (1+ i)))))

  ; צלע ימין (BR → TR)
  (if (> nh 0)
    (progn (setq i 1)
      (while (<= i nh)
        (setq tp (/ (float i) (+ nh 1))
              ep (cdt:lerp (list (car br) (+ (cadr br) CDT:INSET))
                           (list (car tr) (- (cadr tr) CDT:INSET)) tp)
              pos (list (- (car ep) CDT:INSET) (cadr ep)))
        (setq ents (append ents (list (cdt:draw-donut pos size layer))))
        (setq i (1+ i)))))

  ; צלע תחתון (BL → BR)
  (if (> nw 0)
    (progn (setq i 1)
      (while (<= i nw)
        (setq tp (/ (float i) (+ nw 1))
              ep (cdt:lerp (list (+ (car bl) CDT:INSET) (cadr bl))
                           (list (- (car br) CDT:INSET) (cadr br)) tp)
              pos (list (car ep) (+ (cadr ep) CDT:INSET)))
        (setq ents (append ents (list (cdt:draw-donut pos size layer))))
        (setq i (1+ i)))))

  ; צלע עליון (TL → TR)
  (if (> nw 0)
    (progn (setq i 1)
      (while (<= i nw)
        (setq tp (/ (float i) (+ nw 1))
              ep (cdt:lerp (list (+ (car tl) CDT:INSET) (cadr tl))
                           (list (- (car tr) CDT:INSET) (cadr tr)) tp)
              pos (list (car ep) (- (cadr ep) CDT:INSET)))
        (setq ents (append ents (list (cdt:draw-donut pos size layer))))
        (setq i (1+ i)))))
  ents)

;;; ============================================================
;;; I. קווי ליידר — מלבן
;;; ============================================================

(defun cdt:leaders-rect (bb-int leader-text leader-layer /
                          w h corners bl br tr tl
                          d1 d2 conn-pt cx cy)
  (setq w  (cdt:bbox-width  bb-int)
        h  (cdt:bbox-height bb-int)
        corners (cdt:bbox-corners bb-int)
        bl (nth 0 corners)  br (nth 1 corners)
        tr (nth 2 corners)  tl (nth 3 corners)
        cx (car  (cdt:bbox-center bb-int))
        cy (cadr (cdt:bbox-center bb-int)))

  (if (>= h w)
    ; הצלע הארוכה אנכית — ליידר יוצא ימינה
    (progn
      (setq d1 (list (- (caddr bb-int) CDT:INSET) (- (cadddr bb-int) CDT:INSET))
            d2 (list (- (caddr bb-int) CDT:INSET) (+ (cadr  bb-int) CDT:INSET))
            conn-pt (list (+ (caddr bb-int) CDT:LEAD-DIST) cy)))
    ; הצלע הארוכה אופקית — ליידר יוצא למעלה
    (progn
      (setq d1 (list (+ (car   bb-int) CDT:INSET) (- (cadddr bb-int) CDT:INSET))
            d2 (list (- (caddr bb-int) CDT:INSET) (- (cadddr bb-int) CDT:INSET))
            conn-pt (list cx (+ (cadddr bb-int) CDT:LEAD-DIST)))))

  (cdt:draw-line d1 conn-pt leader-layer)
  (cdt:draw-line d2 conn-pt leader-layer)
  (cdt:draw-text-center conn-pt 2.5 "Standard" leader-text leader-layer 0)
  conn-pt)

;;; ============================================================
;;; J. צורה סמלית — אוגן
;;; ============================================================

(defun cdt:draw-stirrup-rect (bb-int stirrup-layer /
                               x0 y0 x1 y1
                               he lx lw
                               p1 p2 p3 p4 p5 p6 p7
                               ename txt-h txt-w)
  (setq x0 (car   bb-int)  y0 (cadr   bb-int)
        x1 (caddr bb-int)  y1 (cadddr bb-int)
        he CDT:HOOK-EXT    lx CDT:HOOK-LEN)

  ; פוליליין אחד רציף: קצה וו1 → וו1 → צלע ימין → תחתון → שמאל → עליון+הרחבה → קצה וו2
  (setq p1 (list (- x1 lx)  (+ y1 he))   ; קצה וו 1
        p2 (list x1          (+ y1 he))   ; פינה ימנית עליונה + הרחבה
        p3 (list x1          y0)          ; פינה ימנית תחתונה
        p4 (list x0          y0)          ; פינה שמאלית תחתונה
        p5 (list x0          y1)          ; פינה שמאלית עליונה
        p6 (list (+ x1 he)   y1)          ; הרחבה ימינה מהפינה
        p7 (list (+ x1 he)   (- y1 lx))) ; קצה וו 2

  (command "_.PLINE" p1 p2 p3 p4 p5 p6 p7 "")
  (setq ename (entlast))
  (cdt:set-layer ename stirrup-layer)

  ; מספר גובה — מסובב 90°, 2 יחידות משמאל ל-x0
  (setq txt-h (rtos (- y1 y0) 2 0))
  (cdt:draw-text-center
    (list (- x0 2.0) (* 0.5 (+ y0 y1)))
    2.5 "Standard" txt-h stirrup-layer 90)

  ; מספר רוחב — אופקי, 2 יחידות מתחת ל-y0
  (setq txt-w (rtos (- x1 x0) 2 0))
  (cdt:draw-text-center
    (list (* 0.5 (+ x0 x1)) (- y0 2.0))
    2.5 "Standard" txt-w stirrup-layer 0))

;;; ============================================================
;;; K. כותרת
;;; ============================================================

(defun cdt:create-title (col-num scale-str cfg top-y cx /
                          h1 h2 lw layer style1 style2
                          gap y2 yl y1
                          half-w x0 x1 txt1 txt2)
  (setq h1     (atof (cdt:get cfg "title-height1"))
        h2     (atof (cdt:get cfg "title-height2"))
        lw     (atoi (cdt:get cfg "title-lweight"))
        layer  (cdt:get cfg "title-layer")
        style1 (cdt:get cfg "title-style1")
        style2 (cdt:get cfg "title-style2"))

  (setq gap (* 0.25 h1))

  ; מיקומי Y (מלמטה למעלה):
  ; top-y → gap h1 → שורה 2 → gap → קו → gap → שורה 1
  (setq y2 (+ top-y h1 (* 0.5 h2))        ; מרכז שורה 2
        yl (+ top-y h1 h2 (* 2.0 gap))    ; קו מפריד
        y1 (+ yl gap (* 0.5 h1)))          ; מרכז שורה 1

  ; אורך קו — מוערך: 10 × h1 כרוחב, + 0.5×h1 מכל צד
  (setq half-w (+ (* 5.0 h1) (* 0.5 h1))
        x0     (- cx half-w)
        x1     (+ cx half-w))

  ; שורה 1
  (setq txt1 (strcat "פרט עמוד מס' " col-num))
  (cdt:draw-text-center (list cx y1) h1 style1 txt1 layer 0)

  ; קו מפריד
  (setq sep-line (cdt:draw-line (list x0 yl) (list x1 yl) layer))
  (if (assoc 370 (entget sep-line))
    (entmod (subst (cons 370 lw) (assoc 370 (entget sep-line)) (entget sep-line)))
    (entmod (append (entget sep-line) (list (cons 370 lw)))))

  ; שורה 2
  (setq txt2 (strcat "1:" scale-str))
  (cdt:draw-text-center (list cx y2) h2 style2 txt2 layer 0))

;;; ============================================================
;;; L. חלון הגדרות — DCL Dialog
;;; ============================================================

(defun cdt:lsp-dir () *cdt-lsp-dir*)

; Write cfg values into the currently-open dialog tiles
(defun cdt:str-or-empty (v) (if (stringp v) v ""))

(defun cdt:dialog-write (cfg)
  (set_tile "ext_layer"     (cdt:str-or-empty (cdt:get cfg "ext-layer")))
  (set_tile "int_layer"     (cdt:str-or-empty (cdt:get cfg "int-layer")))
  (set_tile "int_offset"    (cdt:str-or-empty (cdt:get cfg "int-offset")))
  (set_tile "donut_layer"   (cdt:str-or-empty (cdt:get cfg "donut-layer")))
  (set_tile "donut_size"    (cdt:str-or-empty (cdt:get cfg "donut-size")))
  (set_tile "leader_text"   (cdt:str-or-empty (cdt:get cfg "leader-text")))
  (set_tile "dim_layer"     (cdt:str-or-empty (cdt:get cfg "dim-layer")))
  (set_tile "dim_style"     (cdt:str-or-empty (cdt:get cfg "dim-style")))
  (set_tile "dim_scale"     (cdt:str-or-empty (cdt:get cfg "dim-scale")))
  (set_tile "title_layer"   (cdt:str-or-empty (cdt:get cfg "title-layer")))
  (set_tile "title_style1"  (cdt:str-or-empty (cdt:get cfg "title-style1")))
  (set_tile "title_height1" (cdt:str-or-empty (cdt:get cfg "title-height1")))
  (set_tile "title_style2"  (cdt:str-or-empty (cdt:get cfg "title-style2")))
  (set_tile "title_height2" (cdt:str-or-empty (cdt:get cfg "title-height2")))
  (set_tile "title_lweight" (cdt:str-or-empty (cdt:get cfg "title-lweight")))
  (set_tile "stirrup_layer" (cdt:str-or-empty (cdt:get cfg "stirrup-layer"))))

; Read all tile values from the open dialog into cfg
(defun cdt:dialog-read (cfg)
  (setq cfg (cdt:set! cfg "ext-layer"     (get_tile "ext_layer")))
  (setq cfg (cdt:set! cfg "int-layer"     (get_tile "int_layer")))
  (setq cfg (cdt:set! cfg "int-offset"    (get_tile "int_offset")))
  (setq cfg (cdt:set! cfg "donut-layer"   (get_tile "donut_layer")))
  (setq cfg (cdt:set! cfg "donut-size"    (get_tile "donut_size")))
  (setq cfg (cdt:set! cfg "leader-text"   (get_tile "leader_text")))
  (setq cfg (cdt:set! cfg "dim-layer"     (get_tile "dim_layer")))
  (setq cfg (cdt:set! cfg "dim-style"     (get_tile "dim_style")))
  (setq cfg (cdt:set! cfg "dim-scale"     (get_tile "dim_scale")))
  (setq cfg (cdt:set! cfg "title-layer"   (get_tile "title_layer")))
  (setq cfg (cdt:set! cfg "title-style1"  (get_tile "title_style1")))
  (setq cfg (cdt:set! cfg "title-height1" (get_tile "title_height1")))
  (setq cfg (cdt:set! cfg "title-style2"  (get_tile "title_style2")))
  (setq cfg (cdt:set! cfg "title-height2" (get_tile "title_height2")))
  (setq cfg (cdt:set! cfg "title-lweight" (get_tile "title_lweight")))
  (setq cfg (cdt:set! cfg "stirrup-layer" (get_tile "stirrup_layer")))
  cfg)

(defun cdt:settings-dialog (cfg-in / dlg-id status done ent ed res ldir)
  (setq *cdt-dlg-vals* cfg-in
        done            nil
        status          0)

  ; Try to load DCL from support path, then from LSP directory
  (setq dlg-id (load_dialog "COLDET"))
  (princ (strcat "\n[D] load_dialog=" (if (numberp dlg-id) (itoa dlg-id) (vl-princ-to-string dlg-id))))
  (if (or (null dlg-id) (and (numberp dlg-id) (< dlg-id 0)))
    (progn
      (setq ldir (cdt:lsp-dir))
      (if ldir
        (setq dlg-id (load_dialog (strcat ldir "\\COLDET.dcl"))))))

  (if (< dlg-id 0)
    (princ "\nשגיאה: לא נמצא COLDET.dcl — בדוק שהקובץ בתיקיית coldet.\n")

    (progn
      (while (not done)
        (if (not (new_dialog "coldet_settings" dlg-id))
          (setq done T)
          (progn
            (cdt:dialog-write *cdt-dlg-vals*)

            ; Each pick button: save tile state → close dialog with pick code
            (action_tile "btn_ext"  "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 2)")
            (action_tile "btn_int"  "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 3)")
            (action_tile "btn_dlay" "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 4)")
            (action_tile "btn_dsz"  "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 5)")
            (action_tile "btn_ltxt" "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 6)")
            (action_tile "btn_dim"  "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 7)")
            (action_tile "btn_tlay" "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 8)")
            (action_tile "btn_tt1"  "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 9)")
            (action_tile "btn_tt2"  "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 10)")
            (action_tile "btn_tlw"  "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 11)")
            (action_tile "btn_stir" "(setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))(done_dialog 12)")

            (setq status (start_dialog))

            (cond

              ; Cancel — 0 או nil
              ((or (null status) (equal status 0))
               (setq done T))

              ; OK — 1 או T (ZWCAD מחזיר T)
              ((or (equal status T) (equal status 1))
               (setq *cdt-dlg-vals* (cdt:dialog-read *cdt-dlg-vals*))
               (cdt:save *cdt-dlg-vals*)
               (princ "\n✓ הגדרות נשמרו.")
               (setq done T))

              ((equal status 2)
               (setq res (cdt:pick-layer "הצבע על קו גיאומטריה חיצונית"))
               (if res (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "ext-layer" res))))

              ((equal status 3)
               (setq res (cdt:pick-layer "הצבע על קו גיאומטריה פנימית"))
               (if res (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "int-layer" res))))

              ((equal status 4)
               (setq res (cdt:pick-layer "הצבע על דונאט קיים"))
               (if res (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "donut-layer" res))))

              ((equal status 5)
               (princ "\nהצבע על דונאט קיים לקריאת גודל: ")
               (setq ent (car (entsel)))
               (if (and ent (assoc 40 (entget ent)))
                 (setq *cdt-dlg-vals*
                   (cdt:set! *cdt-dlg-vals* "donut-size"
                     (rtos (* 2.0 (cdr (assoc 40 (entget ent)))) 2 4)))))

              ((equal status 6)
               (initget "Block Text Type")
               (setq res (getkword "\nסוג טקסט ליידר [Block/Text/Type] <Type>: "))
               (cond
                 ((equal res "Block")
                  (princ "\nהצבע על הבלוק: ")
                  (setq ent (car (entsel)))
                  (if (and ent (assoc 2 (entget ent)))
                    (setq *cdt-dlg-vals*
                      (cdt:set! *cdt-dlg-vals* "leader-text"
                        (cdr (assoc 2 (entget ent)))))))
                 ((equal res "Text")
                  (princ "\nהצבע על הטקסט: ")
                  (setq ent (car (entsel)))
                  (if (and ent (assoc 1 (entget ent)))
                    (setq *cdt-dlg-vals*
                      (cdt:set! *cdt-dlg-vals* "leader-text"
                        (cdr (assoc 1 (entget ent)))))))
                 (t
                  (setq res (getstring t "\nהזן טקסט ליידר: "))
                  (if (and res (not (equal res "")))
                    (setq *cdt-dlg-vals*
                      (cdt:set! *cdt-dlg-vals* "leader-text" res))))))

              ((equal status 7)
               (princ "\nהצבע על מידה קיימת: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (setq *cdt-dlg-vals*
                     (cdt:set! *cdt-dlg-vals* "dim-layer" (cdr (assoc 8 ed))))
                   (if (assoc 3 ed)
                     (setq *cdt-dlg-vals*
                       (cdt:set! *cdt-dlg-vals* "dim-style"
                         (cdr (assoc 3 ed))))))))

              ((equal status 8)
               (setq res (cdt:pick-layer "הצבע על אובייקט שכבת כותרת"))
               (if res (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "title-layer" res))))

              ((equal status 9)
               (princ "\nהצבע על טקסט לגודל שורה 1: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (if (assoc 7 ed)
                     (setq *cdt-dlg-vals*
                       (cdt:set! *cdt-dlg-vals* "title-style1" (cdr (assoc 7 ed)))))
                   (if (assoc 40 ed)
                     (setq *cdt-dlg-vals*
                       (cdt:set! *cdt-dlg-vals* "title-height1"
                         (rtos (cdr (assoc 40 ed)) 2 4)))))))

              ((equal status 10)
               (princ "\nהצבע על טקסט לגודל שורה 2: ")
               (setq ent (car (entsel)))
               (if ent
                 (progn
                   (setq ed (entget ent))
                   (if (assoc 7 ed)
                     (setq *cdt-dlg-vals*
                       (cdt:set! *cdt-dlg-vals* "title-style2" (cdr (assoc 7 ed)))))
                   (if (assoc 40 ed)
                     (setq *cdt-dlg-vals*
                       (cdt:set! *cdt-dlg-vals* "title-height2"
                         (rtos (cdr (assoc 40 ed)) 2 4)))))))

              ((equal status 11)
               (princ "\nהצבע על קו לקריאת עובי: ")
               (setq ent (car (entsel)))
               (if (and ent (assoc 370 (entget ent)))
                 (setq *cdt-dlg-vals*
                   (cdt:set! *cdt-dlg-vals* "title-lweight"
                     (itoa (cdr (assoc 370 (entget ent))))))))

              ((equal status 12)
               (setq res (cdt:pick-layer "הצבע על אובייקט שכבת האוגן"))
               (if res (setq *cdt-dlg-vals* (cdt:set! *cdt-dlg-vals* "stirrup-layer" res))))))))

      (unload_dialog dlg-id)))

  (if (= status 1) *cdt-dlg-vals* cfg-in))

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
    (cdt:settings-dialog (cdt:defaults))))

;;; ============================================================
;;; M. הפקודה הראשית — C:COLDET
;;; ============================================================

(defun C:COLDET (/ cfg sel ename col-num shape
                   verts bb-ext bb-int offset
                   donut-size donut-layer
                   top-y cx
                   use-xdata col-input scale-str)
  (vl-load-com)

  ;; טעינת הגדרות
  (setq cfg (cdt:load))
  (if (null cfg) (setq cfg (cdt:first-run)))

  ;; בחירת אובייקט (או Settings)
  (initget "Settings")
  (setq sel (entsel "\nהצבע על קו החוץ של העמוד [Settings]: "))

  (cond
    ;; המשתמש בחר Settings
    ((= sel "Settings")
     (setq cfg (cdt:settings-dialog cfg)))

    ;; לא נבחר כלום
    ((null sel)
     (princ "\nבוטל."))

    ;; נבחר אובייקט — המשך
    (t
     (setq ename (car sel))

     ;; קריאת XData
     (setq col-num (cdt:read-colnum ename))

     ;; זיהוי צורה
     (setq shape (cdt:detect-shape ename))
     (if (null shape)
       (progn (princ "\nצורה לא מוכרת — בחר קו חוץ של עמוד.") (exit)))

     ;; נתוני הגדרות נפוצים
     (setq offset      (atof (cdt:get cfg "int-offset"))
           donut-size  (atof (cdt:get cfg "donut-size"))
           donut-layer (cdt:get cfg "donut-layer"))

     ;; ─── מסלול מלבן ───────────────────────────────────────
     (if (= shape "rect")
       (progn
         (setq verts  (cdt:get-poly-verts ename)
               bb-ext (cdt:bbox-from-verts verts)
               bb-int (cdt:bbox-inset bb-ext offset))

         ;; גיאומטריה חיצונית
         (cdt:draw-closed-rect bb-ext (cdt:get cfg "ext-layer"))

         ;; גיאומטריה פנימית
         (cdt:draw-closed-rect bb-int (cdt:get cfg "int-layer"))

         ;; דונאטים
         (cdt:place-corner-donuts bb-int donut-size donut-layer)
         (cdt:place-edge-donuts   bb-int donut-size donut-layer)

         ;; קווי ליידר
         (cdt:leaders-rect bb-int
                           (cdt:get cfg "leader-text")
                           (cdt:get cfg "dim-layer"))

         ;; צורה סמלית
         (cdt:draw-stirrup-rect bb-int (cdt:get cfg "stirrup-layer"))

         ;; Y עליון ומרכז X לכותרת
         (setq top-y (cadddr bb-ext)
               cx    (* 0.5 (+ (car bb-ext) (caddr bb-ext))))))

     ;; ─── מסלול עיגול ──────────────────────────────────────
     (if (= shape "circle")
       (progn
         (princ "\n[מסלול עיגול — בפיתוח]")
         (setq top-y 0  cx 0)))

     ;; ─── מסלול צורת ר ─────────────────────────────────────
     (if (= shape "lshape")
       (progn
         (princ "\n[מסלול צורת ר — בפיתוח]")
         (setq top-y 0  cx 0)))

     ;; ─── כותרת ────────────────────────────────────────────
     ;; שאלה על XData
     (if col-num
       (progn
         (initget "Yes No")
         (setq use-xdata
           (getkword
             (strcat "\nנמצא מספר עמוד: " col-num
                     " — להשתמש בו? [Yes/No] <Yes>: ")))
         (if (= use-xdata "No")
           (setq col-num (getstring t "\nהזן מספר/תוכן לכותרת: "))))
       (setq col-num (getstring t "\nהזן מספר עמוד: ")))

     ;; קנה מידה
     (setq scale-str (getstring (strcat "\nקנ\"מ 1:")))
     (if (= scale-str "") (setq scale-str "?"))

     ;; יצירת כותרת
     (cdt:create-title col-num scale-str cfg top-y cx)

     (princ "\n✓ COLDET הושלם.")))

  (princ))

;;; ─── הודעת טעינה ─────────────────────────────────────────────
(princ "\nCOLDET 1.1 טעון. הפעל: COLDET\n")
(princ)
