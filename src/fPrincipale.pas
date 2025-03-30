/// <summary>
/// ***************************************************************************
///
/// Colblor Viewer
///
/// Copyright 2021-2025 Patrick PREMARTIN under AGPL 3.0 license.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
/// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
/// DEALINGS IN THE SOFTWARE.
///
/// ***************************************************************************
///
/// Author(s) :
/// Patrick PREMARTIN
///
/// Site :
/// https://colblor.gamolf.fr
///
/// Project site :
/// https://github.com/DeveloppeurPascal/Colblor-Viewer
///
/// ***************************************************************************
/// File last update : 2025-03-30T18:10:54.000+02:00
/// Signature : e150437fbf462cff7b506ea2087e8684fd26664e
/// ***************************************************************************
/// </summary>

unit fPrincipale;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  fAncetreFicheTraduite,
  FMX.Layouts,
  System.Generics.Collections,
  uTournoiAPI,
  cGrilleDeJeu,
  FMX.Objects,
  FMX.Effects;

type
  TListeJoueurs = TObjectDictionary<string, tgrilledejeu>;

  TfrmPrincipale = class(T_AncetreFicheTraduite)
    vsbMosaiqueDesEcrans: TVertScrollBox;
    flMosaiqueDesEcrans: TFlowLayout;
    timerGetGrillesPartiesEncours: TTimer;
    AfficheGagnantBackground: TRectangle;
    AfficheGagnantTexte: TText;
    AfficheGagnant: TLayout;
    GlowEffect1: TGlowEffect;
    procedure timerGetGrillesPartiesEncoursTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FIDPartieEnCours: string;
    FListeJoueurs: TListeJoueurs;
    procedure SetIDPartieEnCours(const Value: string);
    procedure CalculeHauteurMosaique;
    procedure AfficherGagnant;
  public
    procedure TraduireTextes; override;
    { Déclarations publiques }
    property IDPartieEnCours: string read FIDPartieEnCours
      write SetIDPartieEnCours;
  end;

var
  frmPrincipale: TfrmPrincipale;

implementation

{$R *.fmx}

uses
  uDMTraductions,
  System.JSON,
  uInfosPartieEnCours;

{ TfrmPrincipale }

procedure TfrmPrincipale.AfficherGagnant;
begin
  AfficheGagnant.Visible := not InfosTournoi.PseudoDuGagnantDeLaPartie.IsEmpty;
  if AfficheGagnant.Visible then
  begin
    AfficheGagnant.BringToFront;
    AfficheGagnantTexte.AutoSize := false;
    // TODO : à traduire
    AfficheGagnantTexte.Text := _('', 'Partie gagnée par') + ' ' +
      InfosTournoi.PseudoDuGagnantDeLaPartie;
    AfficheGagnantTexte.AutoSize := true;
  end;
end;

procedure TfrmPrincipale.CalculeHauteurMosaique;
var
  i: integer;
  c: tcontrol;
  NewHeight: single;
  CHeight: single;
begin
  NewHeight := 0;
  for i := 0 to flMosaiqueDesEcrans.ChildrenCount - 1 do
    if (flMosaiqueDesEcrans.Children[i] is tcontrol) then
    begin
      c := (flMosaiqueDesEcrans.Children[i] as tcontrol);
      CHeight := c.Margins.Top + c.Height + c.Margins.Bottom;
      if (NewHeight < c.Position.y + CHeight) then
        NewHeight := c.Position.y + CHeight;
    end;
  flMosaiqueDesEcrans.Height := flMosaiqueDesEcrans.Padding.Top + NewHeight +
    flMosaiqueDesEcrans.Padding.Bottom;
end;

procedure TfrmPrincipale.FormCreate(Sender: TObject);
begin
  inherited;
{$IFDEF DEBUG}
{$IFDEF MSWINDOWS}
  // WampServer en local
  // TournoiAPIServeurURL('http://colblorserver/');
  TournoiAPIServeurURL('https://colblor.gamolf.fr/ColblorServer/');
  // TODO : remettre serveur de test en DEBUD
{$ELSE}
  // WampServer en réseau local sur VM Twitch
  // TournoiAPIServeurURL('http://192.168.1.169/');
  TournoiAPIServeurURL('https://colblor.gamolf.fr/ColblorServer/');
  // TODO : remettre serveur de test en DEBUD
{$ENDIF}
{$ELSE}
  // en production sur le serveur web
  TournoiAPIServeurURL('https://colblor.gamolf.fr/ColblorServer/');
{$ENDIF}
  timerGetGrillesPartiesEncours.Enabled := true;
  FListeJoueurs := TListeJoueurs.Create([doOwnsValues]);
  AfficherGagnant;
end;

procedure TfrmPrincipale.FormDestroy(Sender: TObject);
begin
  inherited;
  FListeJoueurs.free;
end;

procedure TfrmPrincipale.FormResize(Sender: TObject);
begin
  inherited;
  CalculeHauteurMosaique;
end;

procedure TfrmPrincipale.SetIDPartieEnCours(const Value: string);
begin
  if (FIDPartieEnCours <> Value) then
  begin
    // Nouvelle partie, on efface les grilles à l'écran
    // while (flMosaiqueDesEcrans.ChildrenCount > 0) do
    // flMosaiqueDesEcrans.Children[0];
    FListeJoueurs.clear;
    CalculeHauteurMosaique;

    // On stocke l'ID de la nouvelle partie
    FIDPartieEnCours := Value;
  end;
end;

procedure TfrmPrincipale.timerGetGrillesPartiesEncoursTimer(Sender: TObject);
begin
  timerGetGrillesPartiesEncours.Enabled := false;
  try
    TournoiAPIgetEcrans(
      procedure(IDPartie: string; ListeJoueurs: TJSONArray)
      var
        k: integer;
        jsaCol, jsaLig: TJSONArray;
        jsv1, jsv2: tjsonvalue;
        i, j: integer;
        idjoueur: string;
        grilledejeu: tgrilledejeu;
      begin
        try
          IDPartieEnCours := IDPartie;
          if assigned(ListeJoueurs) then
            for k := 0 to ListeJoueurs.Count - 1 do
            begin
              try
                idjoueur := ((ListeJoueurs[k] as tjsonobject)
                  .GetValue('IDJoueur') as tjsonstring).Value;
              except
                continue;
              end;
              if FListeJoueurs.ContainsKey(idjoueur) then
              begin
                // Joueur déjà à l'écran => mise à jour
                grilledejeu := FListeJoueurs[idjoueur];
                try
                  // La grille peut être un TJSONArray ou un TJSONBool(false)
                  jsaLig := (ListeJoueurs[k] as tjsonobject).GetValue('Grille')
                    as TJSONArray;
                  j := 0;
                  for jsv1 in jsaLig do
                  begin
                    jsaCol := jsv1 as TJSONArray;
                    i := 0;
                    for jsv2 in jsaCol do
                    begin
                      InfosTournoi.Grille[i, j] :=
                        TCouleurDesCases((jsv2 as TJSONNumber).AsInt);
                      inc(i);
                    end;
                    inc(j);
                  end;
                  grilledejeu.RemplirLaGrilleDepuisGrilleTournoi;
                except
                  // La grille peut ne pas être renseignée
                end;
              end
              else
              begin
                // Joueur pas à l'écran => création
                grilledejeu := tgrilledejeu.Create(self);
                grilledejeu.Name := '';
                grilledejeu.parent := flMosaiqueDesEcrans;
                grilledejeu.width := 250;
                grilledejeu.Height := 250;
                grilledejeu.AfficherLaGrille;
                try
                  grilledejeu.tagstring := ((ListeJoueurs[k] as tjsonobject)
                    .GetValue('Pseudo') as tjsonstring).Value;
                except
                  grilledejeu.tagstring := 'n/a';
                end;
                try
                  // La grille peut être un booléen à false ou un tableau.
                  // si c'est "false", on attend le refresh avant de l'afficher
                  // sinon on la remplit et l'affiche
                  jsaLig := (ListeJoueurs[k] as tjsonobject).GetValue('Grille')
                    as TJSONArray;
                  j := 0;
                  for jsv1 in jsaLig do
                  begin
                    jsaCol := jsv1 as TJSONArray;
                    i := 0;
                    for jsv2 in jsaCol do
                    begin
                      InfosTournoi.Grille[i, j] :=
                        TCouleurDesCases((jsv2 as TJSONNumber).AsInt);
                      inc(i);
                    end;
                    inc(j);
                  end;
                  grilledejeu.RemplirLaGrilleDepuisGrilleTournoi;
                except
                  // la grille est non renseignée
                end;
                FListeJoueurs.Add(idjoueur, grilledejeu);
                tthread.ForceQueue(nil,
                  procedure
                  begin
                    CalculeHauteurMosaique;
                  end);
              end;
            end;
        finally
          AfficherGagnant;
          timerGetGrillesPartiesEncours.Enabled := true;
        end;
      end,
      procedure
      begin
        timerGetGrillesPartiesEncours.Enabled := true;
      end);
  except
    timerGetGrillesPartiesEncours.Enabled := true;
  end;
end;

procedure TfrmPrincipale.TraduireTextes;
begin
  inherited;
  caption := _('TitreViewer', 'Colblor Viewer'); // TODO : à traduire
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
