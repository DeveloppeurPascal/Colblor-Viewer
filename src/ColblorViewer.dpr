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
/// File last update : 2025-03-30T18:07:02.510+02:00
/// Signature : 3e16557cb8eeee3a276968d63a3411bfef9d8cc0
/// ***************************************************************************
/// </summary>

program ColblorViewer;

uses
  System.StartUpCopy,
  FMX.Forms,
  uDMTraductions in '..\lib-externes\Colblor-Translator\src\uDMTraductions.pas' {dmTraductions: TDataModule},
  fAncetreFicheTraduite in '..\lib-externes\Colblor-Translator\src\fAncetreFicheTraduite.pas' {_AncetreFicheTraduite},
  fAncetreCadreTraduit in '..\lib-externes\Colblor-Translator\src\fAncetreCadreTraduit.pas' {_AncetreCadreTraduit: TFrame},
  fPrincipale in 'fPrincipale.pas' {frmPrincipale},
  cGrilleDeJeu in '..\lib-externes\Colblor\src\cGrilleDeJeu.pas' {GrilleDeJeu: TFrame},
  uInfosPartieEnCours in '..\lib-externes\Colblor\src\uInfosPartieEnCours.pas',
  uTournoiAPI in '..\lib-externes\Colblor\src\uTournoiAPI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipale, frmPrincipale);
  Application.Run;
end.
